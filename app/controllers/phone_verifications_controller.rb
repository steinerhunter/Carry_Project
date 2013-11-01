class PhoneVerificationsController < ApplicationController
  def phone_check
    @phone = Phone.find_by_verification_code(params[:verification_code])
    @user = User.find_by_id(params[:user_id])
    if @phone.present?
      if @phone.verified
        flash[:profile_update] = "You've already confirmed your phone number."
      else
        flash[:profile_update] = "You've successfully confirmed your phone number!"
        @phone.confirm_phone
      end
    else
      flash[:profile_update] = "Sorry, that's an invalid verification code."
    end
    redirect_to user_path(@user.id)
  end
end