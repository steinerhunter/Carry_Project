class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:show, :edit, :update, :destroy]
  before_filter :correct_user, only: [:edit, :update]
  before_filter :admin_user, only: [:destroy, :index]
  respond_to :html, :js

  def show
    @user = User.find(params[:id])
    @phone = Phone.find_by_user_id(@user.id)
    @user_transporter_reviews = UserReview.find_all_by_to_user_id_and_job_type(@user.id,"TRANSPORTER")
    @user_sender_reviews = UserReview.find_all_by_to_user_id_and_job_type(@user.id,"SENDER")
  end

  def new
    if signed_in?
      redirect_to root_path
    end
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.only_facebook = false
    if @user.save
      if session[:request_delivery_what].present?
        @request_delivery = RequestDelivery.new
        @request_delivery.what = session[:request_delivery_what]
        @request_delivery.from = session[:request_delivery_from]
        @request_delivery.to = session[:request_delivery_to]
        @request_delivery.cost = session[:request_delivery_cost]
        @request_delivery.currency = session[:request_delivery_currency]
        @request_delivery.user = @user
        @request_delivery.save
        session[:request_delivery_id] = @request_delivery.id
      elsif session[:suggest_delivery_size].present?
        @suggest_delivery = SuggestDelivery.new
        @suggest_delivery.size = session[:suggest_delivery_size]
        @suggest_delivery.from = session[:suggest_delivery_from]
        @suggest_delivery.to = session[:suggest_delivery_to]
        @suggest_delivery.cost = session[:suggest_delivery_cost]
        @suggest_delivery.currency = session[:suggest_delivery_currency]
        @suggest_delivery.user = @user
        @suggest_delivery.save
        session[:suggest_delivery_id] = @suggest_delivery.id
      end
      sign_in @user
      respond_with(@user, :location => root_path)
    end
  end

  def verify
    @user = User.find(params[:id])
    @user.send_email_confirmation_request
    if session[:request_delivery_what].present?
      session[:request_delivery_what] = nil
      session[:request_delivery_from]  = nil
      session[:request_delivery_to] = nil
      session[:request_delivery_cost] = nil
      session[:request_delivery_currency] = nil
      @request_delivery = RequestDelivery.find_by_id(session[:request_delivery_id])
      session[:request_delivery_id] = nil
      redirect_to request_delivery_url(@request_delivery)
    elsif session[:suggest_delivery_size].present?
      session[:suggest_delivery_from]  = nil
      session[:suggest_delivery_to] = nil
      session[:suggest_delivery_cost] = nil
      session[:suggest_delivery_currency] = nil
      @suggest_delivery = SuggestDelivery.find_by_id(session[:suggest_delivery_id])
      session[:suggest_delivery_id] = nil
      redirect_to suggest_delivery_url(@suggest_delivery)
    else
      url = session[:return_to] || root_path
      session[:return_to] = nil if session[:return_to].present?
      redirect_to url
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "You've successfully deleted your account."
    redirect_to users_url
  end

  def edit
  end

  def update
       if @user.update_attributes( params[:user])
        flash[:profile_update] = "Your Profile was successfully updated!"
        sign_in @user
        respond_with(@user, :location => user_path(@user))
      end
  end

  def index
    @users = User.all
  end

  def empty_trash
    current_user.mailbox.trash.each do |conversation|
      conversation.receipts_for(current_user).update_all(:deleted => true)
    end
    redirect_to conversations_path
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to :back unless current_user?(@user) && !current_user.only_facebook
    end

    def admin_user
      redirect_to root_path unless current_user.admin?
    end

end
