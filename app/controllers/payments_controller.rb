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
      currency = request_delivery.currency
    elsif req_or_sugg == "suggest_delivery"
      suggest_delivery = SuggestDelivery.find_by_id(params[:task_id])
      accepted_task = AcceptedSuggest.find_by_id(params[:accepted_task_id])
      suggest_payment = SuggestPayment.find_by_suggest_delivery_id(suggest_delivery.id)
      amount = suggest_delivery.cost.to_f
      currency = suggest_delivery.currency
    end
    seller_amount = 0.85*amount.to_f
    commission_amount = 0.15*amount.to_f

    preapproval_request = PaypalAdaptive::Request.new

    data = {
        "returnUrl" => details_url(accepted_task,req_or_sugg),
        "requestEnvelope" => { "errorLanguage" => "en_US" },
        "currencyCode" => currency,
        "receiverList"=> {
            "receiver"=> [
                { "email" => confirmed_user.email, "amount" => seller_amount, "primary" => false },
                { "email" => "salomon.omer-facilitator@gmail.com", "amount" =>commission_amount, "primary" => false }
            ]
        },
        "maxAmountPerPayment" => amount,
        "maxNumberOfPayments" => 1,
        "maxTotalAmountOfAllPayments" => amount,
        "cancelUrl" => activity_url,
        "ipnNotificationUrl" => ipn_notification_url,
        "startingDate" => Time.now,
        "endingDate" => 11.months.from_.now
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
                                :preapprovalKey => preapproval_response["preapprovalKey"])
        elsif req_or_sugg == "suggest_delivery"
          SuggestPayment.create(:user_id => current_user.id,
                                :suggest_delivery_id => suggest_delivery.id,
                                :status => preapproval_details_response["status"],
                                :preapprovalKey => preapproval_response["preapprovalKey"])
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

  def cancel
    req_or_sugg = params[:req_or_sugg]
    if req_or_sugg == "request_delivery"
      request_delivery = RequestDelivery.find_by_id(params[:task_id])
      accepted_task = AcceptedRequest.find_by_id(params[:accepted_task_id])
      request_payment = RequestPayment.find_by_request_delivery_id(request_delivery.id)
      if request_delivery.when.present? && (Time.now + 3.days > request_delivery.when)
        redirect_to activity_url
      end
      cancel_data = {
          "preapprovalKey" => request_payment.preapprovalKey,
          "requestEnvelope" => { "errorLanguage" => "en_US" }
      }
    elsif req_or_sugg == "suggest_delivery"
      suggest_delivery = SuggestDelivery.find_by_id(params[:task_id])
      accepted_task= AcceptedSuggest.find_by_id(params[:accepted_task_id])
      suggest_payment = SuggestPayment.find_by_suggest_delivery_id(suggest_delivery.id)
      if suggest_delivery.when.present? && (Time.now + 3.days > suggest_delivery.when)
        redirect_to activity_url
      end
      task = suggest_delivery
      cancel_data = {
          "preapprovalKey" => suggest_payment.preapprovalKey,
          "requestEnvelope" => { "errorLanguage" => "en_US" }
      }
    end

    cancel_request = PaypalAdaptive::Request.new

    cancel_response = cancel_request.cancel_preapproval(cancel_data)

    if cancel_response.success?
      if req_or_sugg == "request_delivery"
        accepted_task.cancel_accepted_request
        request_delivery.unconfirm_request
        request_payment.destroy
      elsif req_or_sugg == "suggest_delivery"
        accepted_task.cancel_accepted_suggest
        suggest_delivery.unconfirm_suggest
        suggest_payment.destroy
      end
      redirect_to activity_path
    else
      session[:error] = cancel_response#pay_response.errors.first['message']
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
      seller_amount = 0.85*amount.to_f
      commission_amount = 0.15*amount.to_f
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
          "preapprovalKey" => request_payment.preapprovalKey,
          "actionType" => "PAY"
      }
    elsif req_or_sugg == "suggest_delivery"
      suggest_delivery = SuggestDelivery.find_by_id(params[:task_id])
      accepted_task= AcceptedSuggest.find_by_id(params[:accepted_task_id])
      suggest_payment = SuggestPayment.find_by_suggest_delivery_id(suggest_delivery.id)
      task = suggest_delivery
      amount = suggest_delivery.cost.to_f
      seller_amount = 0.85*amount.to_f
      commission_amount = 0.15*amount.to_f
      preapproval_data = {
          "returnUrl" => details_url(accepted_task,req_or_sugg),
          "requestEnvelope" => { "errorLanguage" => "en_US" },
          "currencyCode" => "USD",
          "receiverList"=> {
              "receiver"=> [
                  { "email" => task_creator.email, "amount" => seller_amount, "primary" => false },
                  { "email" => "salomon.omer-facilitator@gmail.com", "amount" =>commission_amount, "primary" => false }
              ]
          },
          "cancelUrl" => activity_url,
          "ipnNotificationUrl" => ipn_notification_url,
          "preapprovalKey" => suggest_payment.preapprovalKey,
          "actionType" => "PAY"
      }
    end

    preapproval_request = PaypalAdaptive::Request.new

    confirm_preapproval_response = preapproval_request.pay(preapproval_data)

    if confirm_preapproval_response.success?
      if req_or_sugg == "request_delivery"
        accepted_task.complete_accepted_request
        request_delivery.complete_request
        redirect_to :controller => 'user_reviews',
                    :action => 'new',
                    :from_user_id => confirmed_user.id,
                    :to_user_id => task_creator.id,
                    :req_or_sugg => req_or_sugg,
                    :job_type => "SENDER",
                    :task_id => task.id
      elsif req_or_sugg == "suggest_delivery"
        accepted_task.complete_accepted_suggest
        suggest_delivery.complete_suggest
        redirect_to :controller => 'user_reviews',
                    :action => 'new',
                    :from_user_id => task_creator.id,
                    :to_user_id => confirmed_user.id,
                    :req_or_sugg => req_or_sugg,
                    :job_type => "SENDER",
                    :task_id => task.id
      end

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
      details_data = {
          "preapprovalKey" => request_payment.preapprovalKey,
          "requestEnvelope" => { "errorLanguage" => "en_US" },
      }
    elsif req_or_sugg == "suggest_delivery"
      accepted_suggest = AcceptedSuggest.find_by_id(params[:accepted_task_id])
      suggest_delivery = SuggestDelivery.find_by_id(accepted_suggest.suggest_delivery_id)
      suggest_payment = SuggestPayment.find_by_suggest_delivery_id(suggest_delivery.id)
      details_data = {
          "preapprovalKey" => suggest_payment.preapprovalKey,
          "requestEnvelope" => { "errorLanguage" => "en_US" },
      }
    end

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