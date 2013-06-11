class SessionsController < ApplicationController
  respond_to :html, :js

  def new
  end

  def create
    user = User.find_by_email(params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_back_or root_url
    else
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end


  def createFacebook
    auth = request.env["omniauth.auth"]
    user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
    session[:user_id] = user.uid
    sign_in user
    redirect_to root_url, :notice => "Signed in!"
  end

  def destroy
    sign_out
    redirect_to root_path
  end

  def destroyFacebook
    session[:user_id] = nil
    redirect_to root_url, :notice => "Signed out!"
  end

end