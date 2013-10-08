class PaymentsController < ApplicationController
  def pay
    payment = Payment.new
    @pay_response = payment.buildApi
    redirect_to "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_ap-payment&paykey="+@pay_response.pay_key
    #render json: @pay_response
  end

  def find
    payment = Payment.new
    @order_response = payment.find(params[:order])
    render json: @order_response
  end
end