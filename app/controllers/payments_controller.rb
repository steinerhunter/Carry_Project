class PaymentsController < ApplicationController
  protect_from_forgery except: :ipn_notification

  def home
  end

  def checkout
    confirmed_user = User.find_by_id(params[:confirmed_user_id])
    task_creator = User.find_by_id(params[:task_creator_id])
    req_or_sugg = params[:req_or_sugg]
    if req_or_sugg == "request_delivery"
      request_delivery = RequestDelivery.find_by_id(params[:task_id])
      accepted_task = AcceptedRequest.find_by_id(params[:accepted_task_id])
      request_payment = RequestPayment.find_by_request_delivery_id(request_delivery.id)
      amount = request_delivery.cost.to_f
    elsif req_or_sugg == "suggest_delivery"
      suggest_delivery = SuggestDelivery.find_by_id(params[:task_id])
      accepted_task = AcceptedSuggest.find_by_id(params[:accepted_task_id])
      #suggest_payment = SuggestPayment.find_by_request_delivery_id(suggest_delivery.id)
      amount = suggest_delivery.cost.to_f
    end
    seller_amount = 0.85*amount.to_f
    commission_amount = 0.15*amount.to_f

    preapproval_request = PaypalAdaptive::Request.new

    data = {
        "returnUrl" => details_url(accepted_task,req_or_sugg),
        "requestEnvelope" => { "errorLanguage" => "en_US" },
        "currencyCode" => "USD",
        "receiverList"=> {
            "receiver"=> [
                { "email" => confirmed_user.email, "amount" => seller_amount, "primary" => false },
                { "email" => "salomon.omer-facilitator@gmail.com", "amount" =>commission_amount, "primary" => false }
            ]
        },
        "maxAmountPerPayment" => amount,
        "maxNumberOfPayments" => 1,
        "cancelUrl" => activity_url,
        "ipnNotificationUrl" => ipn_notification_url,
        "startingDate" => Time.now
    }

    preapproval_response = preapproval_request.preapproval(data)

    if preapproval_response.success?
      details_data = {
          "preapprovalKey" => preapproval_response["preapprovalKey"],
          "requestEnvelope" => { "errorLanguage" => "en_US" },
      }
      preapproval_details_response = preapproval_request.preapproval_details(details_data)
      if preapproval_details_response.success?
        redirect_to preapproval_response.preapproval_paypal_payment_url
        if req_or_sugg == "request_delivery"
          RequestPayment.create(:user_id => current_user.id,
                                :request_delivery_id => request_delivery.id,
                                :status => preapproval_details_response["status"],
                                :payKey => preapproval_response["preapprovalKey"])
        elsif req_or_sugg == "suggest_delivery"
          SuggestPayment.create(:user_id => current_user.id,
                                :suggest_delivery_id => suggest_delivery.id,
                                :status => preapproval_details_response["status"],
                                :payKey => preapproval_response["preapprovalKey"])
        end
      else
        session[:error] = preapproval_details_response#pay_response.errors.first['message']
        redirect_to fail_url
      end
    else
      session[:error] = preapproval_response#pay_response.errors.first['message']
      redirect_to fail_url
    end
  end

  def execute
    confirmed_user = User.find_by_id(params[:confirmed_user_id])
    task_creator = User.find_by_id(params[:task_creator_id])
    req_or_sugg = params[:req_or_sugg]
    if req_or_sugg == "request_delivery"
      request_delivery = RequestDelivery.find_by_id(params[:task_id])
      accepted_task = AcceptedRequest.find_by_id(params[:accepted_task_id])
      request_payment = RequestPayment.find_by_request_delivery_id(request_delivery.id)
      task = request_delivery
      amount = request_delivery.cost.to_f
    elsif req_or_sugg == "suggest_delivery"
      suggest_delivery = SuggestDelivery.find_by_id(params[:task_id])
      accepted_task= AcceptedSuggest.find_by_id(params[:accepted_task_id])
      #suggest_payment = SuggestPayment.find_by_request_delivery_id(suggest_delivery.id)
      task = suggest_delivery
      amount = suggest_delivery.cost.to_f
    end
    seller_amount = 0.85*amount.to_f
    commission_amount = 0.15*amount.to_f

    preapproval_request = PaypalAdaptive::Request.new

    preapproval_data = {
        "returnUrl" => details_url(accepted_task,req_or_sugg),
        "requestEnvelope" => { "errorLanguage" => "en_US" },
        "currencyCode" => "USD",
        "receiverList"=> {
            "receiver"=> [
                { "email" => confirmed_user.email, "amount" => seller_amount, "primary" => false },
                { "email" => "salomon.omer-facilitator@gmail.com", "amount" =>commission_amount, "primary" => false }
            ]
        },
        "cancelUrl" => activity_url,
        "ipnNotificationUrl" => ipn_notification_url,
        "preapprovalKey" => request_payment.payKey,
        "actionType" => "PAY"
    }

    confirm_preapproval_response = preapproval_request.pay(preapproval_data)

    if confirm_preapproval_response.success?
      if req_or_sugg == "request_delivery"
        accepted_task.complete_accepted_request
        request_delivery.complete_request
      elsif req_or_sugg == "suggest_delivery"
        accepted_task.complete_accepted_suggest
        suggest_delivery.complete_suggest
      end
      redirect_to :controller => 'user_reviews',
                  :action => 'new',
                  :from_user_id => confirmed_user.id,
                  :to_user_id => task_creator.id,
                  :req_or_sugg => req_or_sugg,
                  :job_type => "SENDER",
                  :task_id => task.id
    else
      session[:error] = confirm_preapproval_response#pay_response.errors.first['message']
      redirect_to fail_url
    end
  end

  def details
    preapproval_details = PaypalAdaptive::Request.new
    req_or_sugg = params[:req_or_sugg]
    if req_or_sugg == "request_delivery"
      accepted_request = AcceptedRequest.find_by_id(params[:accepted_task_id])
      request_delivery = RequestDelivery.find_by_id(accepted_request.request_delivery_id)
      request_payment = RequestPayment.find_by_request_delivery_id(request_delivery.id)
    elsif req_or_sugg == "suggest_delivery"
      accepted_suggest = AcceptedSuggest.find_by_id(params[:accepted_task_id])
      suggest_delivery = SuggestDelivery.find_by_id(accepted_suggest.suggest_delivery_id)
      #suggest_payment = SuggestPayment.find_by_suggest_delivery_id(suggest_delivery.id)
    end

    details_data = {
        "preapprovalKey" => request_payment.payKey,
        "requestEnvelope" => { "errorLanguage" => "en_US" },
    }

    preapproval_details_response = preapproval_details.preapproval_details(details_data)

    if preapproval_details_response.success?
      if req_or_sugg == "request_delivery"
        request_payment.approved = preapproval_details_response["approved"]
        request_payment.status = preapproval_details_response["status"]
        request_payment.save
        if request_payment.status == "ACTIVE" && request_payment.approved == true
          accepted_request.confirm_accepted_request
          request_delivery.confirm_request
        end
      elsif req_or_sugg == "suggest_delivery"
        suggest_payment.approved = preapproval_details_response["approved"]
        suggest_payment.status = preapproval_details_response["status"]
        suggest_payment.save
        if suggest_payment.status == "ACTIVE" && suggest_payment.approved == true
          accepted_suggest.confirm_accepted_suggest
          suggest_delivery.confirm_suggest
        end
      end

      redirect_to activity_url
    else
      session[:error] = preapproval_details_response#pay_response.errors.first['message']
      redirect_to fail_url
    end
  end

  def fail
  end

  def ipn_notification
    ipn = PaypalAdaptive::IpnNotification.new
    ipn.send_back(request.raw_post)

    if ipn.verified?
      logger.info "Success"
    else
      logger.info "Trace Error"
    end

    render nothing: true
  end

end