class BillingController < ApplicationController
  before_filter :get_payment, :only => [:checkout, :paypal, :thank_you]

  def new
    @payment = Payment.new
  end

  def create
    @payment = Payment.new(params[:payment])
    if @payment.save
      ## Paypal Checkout page
      redirect_to billing_url(@payment)
    else
      render :action => :new
    end
  end

  # ASSUMPTION   # payment is valid i.e. amount is entered
  def checkout
    response = @payment.setup_purchase(:ip => request.remote_ip, :return_url => confirm_paypal_url(@payment), :cancel_return_url => root_url)
    redirect_to @payment.redirect_url_for(response.token)
  end

  ## CALL BACK
  def paypal
    @payment = @payment.purchase(:token => params[:token], :payer_id => params[:PayerID], :ip => request.remote_ip)
    @payment.save
    redirect_to thank_you_billing_url(@order)
  end

  private
  def get_payment
    @payment = Payment.find_by_id(params[:id])
    @payment && @payment.valid? || invalid_url
  end
end