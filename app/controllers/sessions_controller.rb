class SessionsController < ApplicationController
  before_filter :correct_user,   only: [:new, :create]
  respond_to :html, :js

  def new
    if session[:request_delivery_what].present?
      flash.now[:success] = "Thank you!<br><div class='sub_flash_text'>We will store your giveaway details temporarily,
                                                    and post them to our database once you sign in.</div>".html_safe
    elsif session[:suggest_delivery_size].present?
      flash.now[:success] = "Thank you!<br><div class='sub_flash_text'>We will store your delivery suggestion details temporarily,
                                                    and post them to our database once you sign in.</div>".html_safe
    end
  end

  def create
    user = User.find_by_email(params[:session][:email].downcase)
    @session = user && (user.only_facebook == false) && user.authenticate(params[:session][:password])
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
      elsif session[:suggest_delivery_size].present?
        @suggest_delivery = SuggestDelivery.new
        @suggest_delivery.size = session[:suggest_delivery_size]
        @suggest_delivery.from = session[:suggest_delivery_from]
        @suggest_delivery.to = session[:suggest_delivery_to]
        @suggest_delivery.cost = session[:suggest_delivery_cost]
        @suggest_delivery.currency = session[:suggest_delivery_currency]
        @suggest_delivery.user = user
        @suggest_delivery.save
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