class ConfirmationsController < ApplicationController
  def confirm
    @user = User.find_by_email_confirmation_token(params[:token])
      if @user.present?
        if @user.email_confirmed
          flash[:failure] = "Sorry!<br><div class='sub_flash_text'>You've already confirmed your email address.</div>".html_safe
        else
          flash[:success] = "Thank you!<br><div class='sub_flash_text'>You've successfully confirmed your Email address.</div>".html_safe
          @user.confirm_user
          sign_in @user
        end
      else
        flash[:failure] = "Sorry!<br><div class='sub_flash_text'>That's an invalid confirmation token..</div>".html_safe
      end
    redirect_to root_path
  end
end