class PaymentsController < ApplicationController
  protect_from_forgery except: :ipn_notification

  def home
  end

  def checkout
    pay_request = PaypalAdaptive::Request.new
    amount = params[:amount].to_f
    seller_amount = 0.85*(params[:amount].to_f)
    data = {
        "returnUrl" => home_url,
        "requestEnvelope" => { "errorLanguage" => "en_US" },
        "currencyCode" => "USD",
        "receiverList"=> {
            "receiver"=> [
                { "email" => params[:seller_paypal_email], "amount" => seller_amount, "primary" => false },
                { "email" => "salomon.omer-facilitator@gmail.com", "amount" =>amount, "primary" => true }
            ]
        },
        "cancelUrl" => home_url,
        "actionType" => "PAY_PRIMARY",
        "ipnNotificationUrl" => ipn_notification_url
    }

    pay_response = pay_request.pay(data)

    if pay_response.success?
      redirect_to pay_response.approve_paypal_payment_url
      RequestPayment.create(:user_id => current_user.id,
                                                       :payKey => pay_response["payKey"])
    else
      session[:error] = pay_response#pay_response.errors.first['message']
      redirect_to fail_url
    end
  end

  def execute
    pay_execute = PaypalAdaptive::Request.new
    @request_payment = RequestPayment.find_by_request_delivery_id(1)
    data = {
        "payKey" => @request_payment.payKey,
        "requestEnvelope" => { "errorLanguage" => "en_US" },
    }

    execute_response = pay_execute.execute_payment(data)

    if execute_response.success?
      redirect_to execute_response.approve_paypal_payment_url
    else
      session[:error] = execute_response#pay_response.errors.first['message']
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