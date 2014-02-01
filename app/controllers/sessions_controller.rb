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
        @request_delivery.size = session[:request_delivery_size]
        @request_delivery.attachment = session[:request_delivery_attachment]
        @request_delivery.user = user
        @request_delivery.save
      elsif session[:take_after_not_signed_in_request_delivery_id].present?
        @request_delivery = RequestDelivery.find_by_id(session[:take_after_not_signed_in_request_delivery_id])
      elsif session[:pick_up_after_not_signed_in_request_delivery_id].present?
        @request_delivery = RequestDelivery.find_by_id(session[:pick_up_after_not_signed_in_request_delivery_id])
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