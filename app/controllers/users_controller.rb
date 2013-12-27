class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:show, :edit, :update, :destroy]
  before_filter :correct_user, only: [:edit, :update]
  before_filter :admin_user, only: [:destroy, :index]
  respond_to :html, :js

  def show
    @user = User.find(params[:id])
    @phone = Phone.find_by_user_id(@user.id)
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
      respond_with(@user, :location => root_path)
    end
  end

  def verify
    @user = User.find(params[:id])
    if Rails.env.production?
      @user.send_email_confirmation_request
      sign_in @user
    end
    if session[:request_delivery_what].present?
      session[:request_delivery_what] = nil
      session[:request_delivery_from]  = nil
      session[:request_delivery_to] = nil
      session[:request_delivery_cost] = nil
      session[:request_delivery_currency] = nil
      @request_delivery = RequestDelivery.find_by_id(session[:request_delivery_id])
      @request_delivery.set_giver
      session[:request_delivery_id] = nil
      if @phone.present?
        if @phone.verified
          @request_delivery.publish
          flash[:success] = "Thank you!<br>
                                              <div class='sub_flash_text'>Your giveaway was successfully added to our lists. <br>
                                              Let's see who wants to take it!</div>".html_safe
        else
          @request_delivery.unpublish
          flash[:success] = "Thank you!<br>
                                              <div class='sub_flash_text'>Your giveaway was successfully added to our lists. <br><br>
                                              Before publishing it, we require that you verify your <b style=\"color:#1a2cff\">phone number</b>.<br>
                                              It shall remain confidential to everyone, until someone comes to pick up the item from you.<br><br>
                                              <a class='verify_item' href=\"/phone_verify/#{current_user.id}\">Verify Phone</a></div>".html_safe
        end
      else
        @request_delivery.unpublish
        flash[:success] = "Thank you!<br>
                                              <div class='sub_flash_text'>Your giveaway was successfully added to our lists. <br><br>
                                              Before publishing it, we require that you <br>add your <b style=\"color:#1a2cff\">phone number</b> and verify it.<br><br>
                                              It shall remain confidential to everyone, <br>except for the person who picks up the item from you.<br><br>
                                              <a class='verify_item' href=\"/phones/new?user_id=#{current_user.id}\">Add Phone</a></div>".html_safe
      end
      redirect_to request_delivery_url(@request_delivery)
    elsif session[:suggest_delivery_size].present?
      session[:suggest_delivery_from]  = nil
      session[:suggest_delivery_to] = nil
      session[:suggest_delivery_cost] = nil
      session[:suggest_delivery_currency] = nil
      @suggest_delivery = SuggestDelivery.find_by_id(session[:suggest_delivery_id])
      session[:suggest_delivery_id] = nil
      flash[:success] = "Thank you!<br>
                                              <div class='sub_flash_text'>Your delivery suggestion was successfully added to our lists. <br>
                                              There are some more details to add though.<br>
                                              <b style=\"color:#ff9054\">Add</b> <img src=\"../assets/missing_detail.png\"> all details and get priority in our lists!</div>".html_safe
      redirect_to suggest_delivery_url(@suggest_delivery)
    else
      url = session[:return_to] || root_path
      session[:return_to] = nil if session[:return_to].present?
      flash[:success] = "Thank you!<br><div class='sub_flash_text'>You've successfully created your account.</div>".html_safe
      redirect_to url
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "Thank you!<br><div class='sub_flash_text'>You've successfully deleted your account.</div>".html_safe
    redirect_to users_url
  end

  def edit
  end

  def update
    if @user.update_attributes( params[:user])
      flash[:success] = "Great!<br><div class='sub_flash_text'>Your details were successfully updated.</div>".html_safe
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
