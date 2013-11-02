class PhonesController < ApplicationController
  respond_to :html, :js

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
    if @user != current_user || @phone.nil?
      redirect_to user_path(current_user.id)
    end
    @phone.generate_verification_code

    #Create and send an SMS message
    client = Twilio::REST::Client.new TWILIO_CONFIG['sid'], TWILIO_CONFIG['token']
    client.account.messages.create(
        :body  =>  "Your sendd.me verification code is #{@phone.verification_code}.",
        :to       => @phone.phone,
        :from  => TWILIO_CONFIG['from']
    )
    redirect_to phone_verify_path(@phone.user_id)
  end

  def verify
    @user = User.find_by_id(params[:user_id])
    @phone = Phone.find_by_user_id(@user.id)
    if @user != current_user || @phone.nil?
      redirect_to user_path(current_user.id)
    end
  end


end
