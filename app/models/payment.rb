class Payment < ActiveRecord::Base

  def pay
    pay_request = PaypalAdaptive::Request.new
    data = {
        :returnUrl => "https://sendwithme.herokuapp.com/adaptive_payments/request",
        :requestEnvelope => {
            :errorLanguage => "en_US" },
        :currencyCode => "USD",
        :receiverList => {
            :receiver => [{
                              :amount => 25.0,
                              :email => "salomon.omer-facilitator@gmail.com",
                              :primary => false,
                              :paymentType => "SERVICE" }] },
        :cancelUrl => "http://sendwithme.herokuapp.com",
        :actionType => "PAY",
        :ipnNotificationUrl => "https://paypal-sdk-samples.herokuapp.com/adaptive_payments/ipn_notify",
    }

    #To do chained payments, just add a primary boolean flag:{“receiver”=> [{"email"=>"PRIMARY", "amount"=>"100.00", "primary" => true}, {"email"=>"OTHER", "amount"=>"75.00", "primary" => false}]}

    pay_response = pay_request.pay(data)

    if pay_response.success?
      # Send user to paypal
      redirect_to pay_response.approve_paypal_payment_url
    else
      puts pay_response.errors.first['message']
      redirect_to "/", notice: "Something went wrong. Please contact support."
    end

  end
end