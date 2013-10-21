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
      accepted_request = AcceptedRequest.find_by_id(params[:accepted_task_id])
      request_payment = RequestPayment.find_by_request_delivery_id(request_delivery.id)
      amount = request_delivery.cost.to_f
    elsif req_or_sugg == "suggest_delivery"
      suggest_delivery = SuggestDelivery.find_by_id(params[:task_id])
      accepted_suggest = AcceptedSuggest.find_by_id(params[:accepted_task_id])
      #suggest_payment = SuggestPayment.find_by_request_delivery_id(suggest_delivery.id)
      amount = suggest_delivery.cost.to_f
    end
    seller_amount = 0.85*amount.to_f

    pay_request = PaypalAdaptive::Request.new

    data = {
        "returnUrl" => details_url(accepted_request),
        "requestEnvelope" => { "errorLanguage" => "en_US" },
        "currencyCode" => "USD",
        "receiverList"=> {
            "receiver"=> [
                { "email" => confirmed_user.email, "amount" => seller_amount, "primary" => false },
                { "email" => "salomon.omer-facilitator@gmail.com", "amount" =>amount, "primary" => true }
            ]
        },
        "cancelUrl" => activity_url,
        "actionType" => "PAY_PRIMARY",
        "ipnNotificationUrl" => ipn_notification_url
    }

    pay_response = pay_request.pay(data)

    if pay_response.success?
      details_data = {
          "payKey" => pay_response["payKey"],
          "requestEnvelope" => { "errorLanguage" => "en_US" },
      }
      paymentdetails_response = pay_request.payment_details(details_data)
      if paymentdetails_response.success?
        redirect_to pay_response.approve_paypal_payment_url
        RequestPayment.create(:user_id => current_user.id,
                              :request_delivery_id => request_delivery.id,
                              :status => paymentdetails_response["status"],
                              :payKey => pay_response["payKey"])
      else
        session[:error] = paymentdetails_response#pay_response.errors.first['message']
        redirect_to fail_url
      end
    else
      session[:error] = pay_response#pay_response.errors.first['message']
      redirect_to fail_url
    end
  end

  def execute
    confirmed_user = User.find_by_id(params[:confirmed_user_id])
    task_creator = User.find_by_id(params[:task_creator_id])
    req_or_sugg = params[:req_or_sugg]
    if req_or_sugg == "request_delivery"
      request_delivery = RequestDelivery.find_by_id(params[:task_id])
      accepted_request = AcceptedRequest.find_by_id(params[:accepted_task_id])
      request_payment = RequestPayment.find_by_request_delivery_id(request_delivery.id)
      task = request_delivery
    elsif req_or_sugg == "suggest_delivery"
      suggest_delivery = SuggestDelivery.find_by_id(params[:task_id])
      accepted_suggest = AcceptedSuggest.find_by_id(params[:accepted_task_id])
      #suggest_payment = SuggestPayment.find_by_request_delivery_id(suggest_delivery.id)
      task = suggest_delivery
    end

    pay_execute = PaypalAdaptive::Request.new

    data = {
        "payKey" => request_payment.payKey,
        "requestEnvelope" => { "errorLanguage" => "en_US" },
    }

    execute_response = pay_execute.execute_payment(data)

    if execute_response.success?
      details_data = {
          "payKey" => request_payment.payKey,
          "requestEnvelope" => { "errorLanguage" => "en_US" },
      }
      paymentdetails_response = pay_execute.payment_details(details_data)
      if paymentdetails_response.success?
        request_payment.status = paymentdetails_response["status"]
        request_payment.save
        if paymentdetails_response["status"] == "COMPLETED"
          if req_or_sugg == "request_delivery"
            accepted_request.complete_accepted_request
            request_delivery.complete_request
          elsif req_or_sugg == "suggest_delivery"
            accepted_suggest.complete_accepted_suggest
            suggest_delivery.complete_suggest
          end
        end
        redirect_to :controller => 'user_reviews',
                                  :action => 'new',
                                  :from_user_id => confirmed_user.id,
                                  :to_user_id => task_creator.id,
                                  :req_or_sugg => req_or_sugg,
                                  :job_type => "SENDER",
                                  :task_id => task.id
      else
        session[:error] = paymentdetails_response#pay_response.errors.first['message']
        redirect_to fail_url
      end
    else
      session[:error] = execute_response#pay_response.errors.first['message']
      redirect_to fail_url
    end
  end

  def details
    payment_details = PaypalAdaptive::Request.new
    accepted_request = AcceptedRequest.find_by_id(params[:accepted_request_id])
    request_delivery = RequestDelivery.find_by_id(accepted_request.request_delivery_id)
    request_payment = RequestPayment.find_by_request_delivery_id(request_delivery.id)

    data = {
        "payKey" => request_payment.payKey,
        "requestEnvelope" => { "errorLanguage" => "en_US" },
    }

    paymentdetails_response = payment_details.payment_details(data)

    if paymentdetails_response.success?
      request_payment.status = paymentdetails_response["status"]
      request_payment.save
      if request_payment.status == "INCOMPLETE"
        accepted_request.confirm_accepted_request
        request_delivery.confirm_request
      end
      redirect_to activity_url
    else
      session[:error] = paymentdetails_response#pay_response.errors.first['message']
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