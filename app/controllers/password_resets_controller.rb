class PasswordResetsController < ApplicationController
  respond_to :html, :js

  def new
  end

  def create
    user = User.find_by_email(params[:email])
    user.send_password_reset if user
    flash[:password_reset] ="We've sent you an email with instructions on how to reset your password."
    redirect_to root_url
  end

  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end

  def admin_reset
    if current_user.try(:admin?)
      @user = User.find_by_id(params[:user_id])
      @user.send_password_reset
      redirect_to users_path
    else
      redirect_to root_path
    end

  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.password_reset_sent_at < 2.hours.ago
      redirect_to new_password_reset_path, :alert => "Password reset has expired."
    elsif @user.update_attributes(params[:user])
      flash[:password_reset] = "You've successfully updated your Password!"
      respond_with(@user, :location => root_path)
    end
  end

end
