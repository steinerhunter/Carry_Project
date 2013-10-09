class Payment
  attr_accessor :api

  def buildApi
    @api = PayPal::SDK::AdaptivePayments::API.new
    pay = @api.build_pay({
                             :actionType => "PAY",
                             :cancelUrl => "http://sendwithme.herokuapp.com",
                             :currencyCode => "USD",
                             :feesPayer => "SENDER",
                             :requestEnvelope => {
                                 :errorLanguage => "en_US" },
                             :ipnNotificationUrl => "https://paypal-sdk-samples.herokuapp.com/adaptive_payments/ipn_notify",
                             :receiverList => {
                                 :receiver => [{
                                                   :amount => 100.0,
                                                   :email => "salomon.omer-facilitator@gmail.com",
                                                   :primary => false,
                                                   :paymentType => "SERVICE" }] },
                             :senderEmail => "thesender@sendwith.me",
                             :returnUrl => "https://paypal-sdk-samples.herokuapp.com/adaptive_payments/pay",
                       })
    # Make API call & get response
    @pay_response = @api.pay(pay)

    # Access Response
    if @pay_response.success?
      @pay_response.payKey
      @pay_response.paymentExecStatus
      @pay_response.payErrorList
      @pay_response.paymentInfoList
      @pay_response.sender
      @pay_response.defaultFundingPlan
      @pay_response.warningDataList
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
 # def loadSDK
   # PayPal::SDK.load('config/paypal.yml', ENV['RACK_ENV'] || 'development')
    #@api = PayPal::SDK::AdaptivePayments::API.new
  #end

end