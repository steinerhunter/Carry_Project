class PhoneVerificationsController < ApplicationController
  def phone_check
    @phone = Phone.find_by_verification_code(params[:verification_code])
    @user = User.find_by_id(@phone.user_id)
    if @phone.present?
      if @phone.verified
        flash[:failure] = "Sorry!<br><div class='sub_flash_text'>You've already confirmed your phone number.</div>".html_safe
        redirect_to user_path(@user.id)
      else
        flash[:success] = "Thank you!<br><div class='sub_flash_text'>Your phone number has been successfully verified..</div>".html_safe
        @phone.confirm_phone
        redirect_to user_path(@user.id)
      end
    else
      flash[:failure] = "Sorry!<br><div class='sub_flash_text'>That's an invalid verification code.</div>".html_safe
      redirect_to root_path
    end
  end
end