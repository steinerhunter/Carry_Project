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
      # an already registered user logs in with Facebook
      msg = "Random message1 for connecting a given account to these Facebook OAuth2 credentials"
      @user = authentication.user
      if current_user.nil?
        sign_in @user
      end
      if session[:request_delivery_what].present?
        @request_delivery = RequestDelivery.new
        @request_delivery.what = session[:request_delivery_what]
        @request_delivery.from = session[:request_delivery_from]
        @request_delivery.size = session[:request_delivery_size]
        @request_delivery.attachment = session[:request_delivery_attachment]
        @request_delivery.user = @user
        @request_delivery.save
        session[:request_delivery_what] = nil
        session[:request_delivery_from] = nil
        session[:request_delivery_size] = nil
        session[:request_delivery_attachment] = nil
        redirect_to request_delivery_url(@request_delivery)
      else
        redirect_after_login
      end
    elsif current_user || user
      # an already logged in user connects its account with Facebook
      @user = current_user ? current_user : user
      @user.authentications.create(:provider => omniauth[:provider], :uid => omniauth[:uid], :image => omniauth['info']['image'], :verified => omniauth['info']['verified'] )
      msg = "Random message2 for connecting a given account to these Facebook OAuth2 credentials"
      flash[:success] = "Thank you!<br><div class='sub_flash_text'>You've successfully confirmed your Facebook account.</div>".html_safe
      if session[:request_delivery_what].present?
        @request_delivery = RequestDelivery.new
        @request_delivery.what = session[:request_delivery_what]
        @request_delivery.from = session[:request_delivery_from]
        @request_delivery.size = session[:request_delivery_size]
        @request_delivery.attachment = session[:request_delivery_attachment]
        @request_delivery.user = @user
        @request_delivery.save
        session[:request_delivery_what] = nil
        session[:request_delivery_from] = nil
        session[:request_delivery_size] = nil
        session[:request_delivery_attachment] = nil
        redirect_to request_delivery_url(@request_delivery)
      else
        redirect_after_login
      end
    else
      # a new user registers with Facebook
      msg = "Random message3 for connecting a given account to these Facebook OAuth2 credentials"
      @user = User.new(:name => omniauth['info']['first_name']+" "+omniauth['info']['last_name'], :email => omniauth['info']['email'], :only_facebook => true, :email_confirmed => true)
      @user.save(:validate => false)
      @user.authentications.create(:provider => omniauth[:provider], :uid => omniauth[:uid], :image => omniauth['info']['image'], :verified => omniauth['info']['verified'] )
      sign_in @user
      if session[:request_delivery_what].present?
        @request_delivery = RequestDelivery.new
        @request_delivery.what = session[:request_delivery_what]
        @request_delivery.from = session[:request_delivery_from]
        @request_delivery.size = session[:request_delivery_size]
        @request_delivery.attachment = session[:request_delivery_attachment]
        @request_delivery.user = @user
        @request_delivery.save
        session[:request_delivery_what] = nil
        session[:request_delivery_from] = nil
        session[:request_delivery_size] = nil
        session[:request_delivery_attachment] = nil
        redirect_to request_delivery_url(@request_delivery)
      else
        redirect_after_login
      end
    end
  end

  def failure
    redirect_to root_path, :alert => "Some error alert with Facebook error: " + params[:message]
  end

  def logout
    sign_out
    reset_session
    redirect_to_callback("Some logout message", params[:callback])
  end

  private

  def login_authenticated(msg)
    # add your login actions here (i.e.: add user_id to session)
    redirect_to_callback(msg)
  end

  def redirect_to_callback(msg, callback = request.env['omniauth.params']['callback'])
    redirect_to (callback.present? ? callback.to_s.force_encoding('utf-8') : root_path)
  end

  def redirect_after_login
    url = session[:return_to] || root_path
    session[:return_to] = nil if session[:return_to].present?
    redirect_to url
  end

end
