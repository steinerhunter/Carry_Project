class PaymentsController < ApplicationController
  protect_from_forgery except: :ipn_notification

  def home
  end

  def checkout
    pay_request = PaypalAdaptive::Request.new

    data = {
        "returnUrl" => home_url,
        "requestEnvelope" => { "errorLanguage" => "en_US" },
        "currencyCode" => "USD",
        "receiverList"=> {
            "receiver"=>[
                { "email" => params[:seller_paypal_email], "amount" => params[:amount], "primary" => false }
            ]
        },
        "cancelUrl" => home_url,
        "actionType" => "PAY",
        "ipnNotificationUrl" => ipn_notification_url
    }

    pay_response = pay_request.pay(data)

    if pay_response.success?
      redirect_to pay_response.approve_paypal_payment_url
    else
      session[:error] = pay_response#pay_response.errors.first['message']
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