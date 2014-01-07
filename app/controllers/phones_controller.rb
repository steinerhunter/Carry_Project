class PhonesController < ApplicationController
  respond_to :html, :js
  require 'twilio-ruby'

  def new
    @phone = Phone.new
    @user = User.find_by_id(params[:user_id])
    @user_has_phone = Phone.find_by_user_id(@user.id)
    if @user != current_user || @user_has_phone.present?
      redirect_to user_path(current_user.id)
    end
  end

  def create
      @phone = Phone.new(params[:phone])
      if @phone.save
        @phone.normalize_number
        respond_with(@phone, :location => root_path)
      end
  end

  def send_code
    @user = User.find_by_id(params[:user_id])
    @phone = Phone.find_by_user_id(@user.id)
    if @user != current_user || @phone.nil? || @phone.verified
      redirect_to user_path(current_user.id)
    end
    @phone.generate_verification_code

    if Rails.env.development?
      @twilio_from = ENV['TWILIO_DEMO_NUMBER']
    elsif Rails.env.production?
      @twilio_from = ENV['TWILIO_PURCHASED_NUMBER']
    end
    @twilio_sid = ENV['TWILIO_SID']
    @twilio_token = ENV['TWILIO_TOKEN']

    #Create and send an SMS message
    client = Twilio::REST::Client.new @twilio_sid, @twilio_token
    client.account.messages.create(
        :body  =>  "Your sendd.me verification code is #{@phone.verification_code}.",
        :to       => @phone.normalized_phone,
        :from  => @twilio_from
    )
    redirect_to phone_verify_path(@phone.user_id)
  end

  def pre_verify_request
    @coming_from = params[:coming_from]
    @my_phone = Phone.find_by_user_id(current_user.id)
    @request_delivery = RequestDelivery.find_by_id(params[:request_delivery_id])
    @accepted_request = AcceptedRequest.find_by_request_delivery_id(@request_delivery.id)
    if @accepted_request.present?
      @confirmed_user = User.find_by_id(@accepted_request.user_id)
    end
    render "pre_verify_request.html.erb", :layout => false
  end

  def pre_verify_suggest
    @coming_from = params[:coming_from]
    @my_phone = Phone.find_by_user_id(current_user.id)
    @suggest_delivery = SuggestDelivery.find_by_id(params[:suggest_delivery_id])
    @accepted_suggest = AcceptedSuggest.find_by_suggest_delivery_id(@suggest_delivery.id)
    if @accepted_suggest.present?
      @confirmed_user = User.find_by_id(@accepted_suggest.user_id)
    end
    render "pre_verify_suggest.html.erb", :layout => false
  end

  def verify
    @user = User.find_by_id(params[:user_id])
    @phone = Phone.find_by_user_id(@user.id)
    if @user != current_user || @phone.nil? || @phone.verified
      redirect_to user_path(current_user.id)
    end
  end


end
