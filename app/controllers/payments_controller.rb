class PaymentsController < ApplicationController
  def pay
    @payment = Payment.new
  end

  def find
    payment = Payment.new
    @order_response = payment.find(params[:order])
    render json: @order_response
  end
end