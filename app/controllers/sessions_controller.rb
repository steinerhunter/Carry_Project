class SessionsController < ApplicationController
  before_filter :correct_user,   only: [:new, :create]
  respond_to :html, :js

  def new
      if session[:request_delivery_what].present?
        flash.now[:request_signin] = "<div class='sub_flash_text'>Thank you</div> for adding your request delivery details.<br><br>
                                                              We will store them temporarily, and post them to our database once you sign in.".html_safe
      end
  end

  def create
    user = User.find_by_email(params[:session][:email].downcase)
    @session = user && user.authenticate(params[:session][:password])
    if @session
      if session[:request_delivery_what].present?
        @request_delivery = RequestDelivery.new
        @request_delivery.what = session[:request_delivery_what]
        @request_delivery.from = session[:request_delivery_from]
        @request_delivery.to = session[:request_delivery_to]
        @request_delivery.cost = session[:request_delivery_cost]
        @request_delivery.currency = session[:request_delivery_currency]
        @request_delivery.user = user
        @request_delivery.save
      end
      sign_in user
      respond_with(user, :location => root_path)
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

  private

  def correct_user
    redirect_to root_path if !current_user.nil?
  end

end