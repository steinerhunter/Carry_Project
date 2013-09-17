class AuthenticationsController < ApplicationController
  # skip_before_filter that save your application by logout

  layout :nil

  # new action is used by the iFrame container within the facebook page
  def new
    render
  end

  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth[:provider], omniauth[:uid])
    user = User.find_by_email(omniauth[:info][:email])
    if authentication
      # a allready registered user logs in with Facebook

      @user = authentication.user
      login_authenticated(msg)
    elsif current_user || user
      # a allready logged in user connects its account with Facebook

      @user = current_user ? current_user : user
      @user.authentications.create(:provider => omniauth[:provider], :uid => omniauth[:uid])
      msg = "Random mmessage for connecting a given account to these Facebook OAuth2 credentials"
      user ? login_authenticated(msg) : redirect_to_callback(msg)
    else
      # a new user registers with Facebook

      @user = User.create()
      @user.authentications.create(:provider => omniauth[:provider], :uid => omniauth[:uid])
      login_authenticated(msg)
    end
  end

  def failure
    redirect_to root_path, :alert => "Some error alert with Facebook error: " + params[:message]
  end

  def logout
    reset_session
    redirect_to_callback("Some logout message", params[:callback])
  end

  private

  def login_authenticated(msg)
    # add your login actions here (i.e.: add user_id to session)
    redirect_to_callback(msg)
  end

  def redirect_to_callback(msg, callback = request.env['omniauth.params']['callback'])
    redirect_to (callback.present? ? callback.to_s.force_encoding('utf-8') : root_path), :notice => msg
  end

end