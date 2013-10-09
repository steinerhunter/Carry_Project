class Payment
  attr_accessor :api

  def buildApi
    loadSDK
    pay = @api.build_pay({
                             :actionType => "PAY",
                             :cancelUrl => "http://sendwithme.herokuapp.com",
                             :currencyCode => "USD",
                             :feesPayer => "SENDER",
                             :ipnNotificationUrl => "https://paypal-sdk-samples.herokuapp.com/adaptive_payments/ipn_notify",
                             :receiverList => {
                                 :receiver => [{
                                                   :amount => 100.0,
                                                   :email => "salomon.omer-facilitator@gmail.com",
                                                   :primary => false,
                                                   :paymentType => "SERVICE" }] },
                             :senderEmail => "thesender@sendwith.me",
                             :returnUrl => "https://paypal-sdk-samples.herokuapp.com/adaptive_payments/pay",
                             :fundingConstraint => {
                                 :allowedFundingType => {
                                     :fundingTypeInfo => [{
                                                              :fundingType => "BALANCE" }] } } })
    # Make API call & get response
    @pay_response = @api.pay(pay)

    # Access Response
    if @pay_response.success?
      @pay_response
    else
      @pay_response.error
    end

  end

  def find(order)
    # Build request object
    @payment_details = @api.build_payment_details({:payKey => order })

    # Make API call & get response
    @payment_details_response = @api.payment_details(@payment_details)
  end

  private
  def loadSDK
    PayPal::SDK.load('config/paypal.yml', ENV['RACK_ENV'] || 'development')
    @api = PayPal::SDK::AdaptivePayments::API.new
  end

end