class PhoneVerificationsController < ApplicationController
  def phone_check
    @phone = Phone.find_by_verification_code(params[:verification_code])
    @user = User.find_by_id(@phone.user_id)
    if @phone.present?
      if @phone.verified
        flash[:failure] = "Sorry!<br><div class='sub_flash_text'>You've already confirmed your phone number.</div>".html_safe
        redirect_to  session[:return_to] || root_path
      else
        flash[:success] = "Thank you!<br><div class='sub_flash_text'>Your phone number has been successfully verified.</div>".html_safe
        @phone.confirm_phone
        gon.phone_confirmed = true
        RequestDelivery.update_all({:sending_phone => @phone.phone}, {:user_id => @user.id})
        if session[:verify_from_request_delivery].present?
          @request_delivery.find_by_id = session[:verify_from_request_delivery]
          @request_delivery.check_all_details
          session[:verify_from_request_delivery] = nil
        end
        redirect_to  session[:return_to] || root_path
      end
    else
      flash[:failure] = "Sorry!<br><div class='sub_flash_text'>That's an invalid verification code.</div>".html_safe
      redirect_to  session[:return_to] || root_path
    end
  end
end