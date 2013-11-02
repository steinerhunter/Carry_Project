class PhonesController < ApplicationController
  respond_to :html, :js

  def new
    @phone = Phone.new
    @user = User.find_by_id(params[:user_id])
    if @user != current_user
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

  def verify
    @user = User.find_by_id(params[:user_id])
    if @user != current_user
      redirect_to user_path(current_user.id)
    end
    @phone = Phone.find_by_user_id(@user.id)
    if @phone.present?
      @phone.generate_verification_code
      client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])

      #Create and send an SMS message
      client.account.sms.messages.create(
          from: TWILIO_CONFIG['from'],
          to: @phone.phone,
          body: "Your sendd.me verification code is #{@phone.verification_code}."
      )
    else
      redirect_to user_path(@user.id)
    end
  end
end
