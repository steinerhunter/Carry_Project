class ConfirmationsController < ApplicationController
  # GET /confirm/<token>
  def confirm
    @user = User.find_by_email_confirmation_token(params[:token])
      if @user.present?
        flash[:profile_update] = "You've successfully confirmed your email address!"
        @user.confirm_user
        sign_in @user
    end
  end
end