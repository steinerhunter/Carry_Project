class ConfirmationsController < ApplicationController
  def confirm
    @user = User.find_by_email_confirmation_token(params[:token])
      if @user.present?
        if @user.email_confirmed
          flash[:profile_update] = "You're already confirmed your email address."
        else
          flash[:profile_update] = "You've successfully confirmed your email address!"
          @user.confirm_user
          sign_in @user
        end
      else
        flash[:profile_update] = "Sorry, that's an invalid confirmation token."
      end
    redirect_to root_path
  end
end