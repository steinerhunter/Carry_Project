class UserReviewsController < ApplicationController
  respond_to :html, :js

  def new
    if current_user.nil?
      redirect_to root_path
    else
      @user_review = UserReview.new
      @other_user = User.find_by_id(params[:to_user_id])
    end
  end

  def create
    @user_review = UserReview.new(params[:user_review])
    if @user_review.save
      @reviewed_user = User.find_by_id(@user_review.to_user_id)
      @reviewed_user.add_review
      @reviewed_user.save
      if @user_review.job_type == "SENDER"
        if @user_review.req_or_sugg == "suggest_delivery"
          @suggest_delivery = SuggestDelivery.find_by_id(@user_review.task_id)
          @suggest_delivery.sender_reviewed = true
          @suggest_delivery.save
        elsif @user_review.req_or_sugg == "request_delivery"
          @request_delivery = RequestDelivery.find_by_id(@user_review.task_id)
          @request_delivery.sender_reviewed = true
          @request_delivery.save
        end
      elsif @user_review.job_type == "TRANSPORTER"
        if @user_review.req_or_sugg == "suggest_delivery"
          @suggest_delivery = SuggestDelivery.find_by_id(@user_review.task_id)
          @suggest_delivery.transporter_reviewed = true
          @suggest_delivery.save
        elsif @user_review.req_or_sugg == "request_delivery"
          @request_delivery = RequestDelivery.find_by_id(@user_review.task_id)
          @request_delivery.transporter_reviewed = true
          @request_delivery.save
        end
        respond_with(@user_review, :location => root_path)
      end
    end
  end

end
