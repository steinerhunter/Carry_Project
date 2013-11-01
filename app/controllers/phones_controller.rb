class PhoneVerificationsController < ApplicationController

  def new
    @user = User.find_by_id(params[:user_id])
  end

  def create

  end

end
