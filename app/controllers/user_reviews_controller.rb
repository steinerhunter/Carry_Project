class UserReviewsController < ApplicationController
  respond_to :html, :js

  def new
    if current_user.nil?
      redirect_to root_path
    else
      @user_review = UserReview.new
      @request_delivery = RequestDelivery.find_by_id(params[:request_delivery_id])
      @taken_giveaway = TakenGiveaway.find_by_request_delivery_id(@request_delivery.id)
      @taking_user = User.find_by_id(@taken_giveaway.user_id)
      @transporter = @request_delivery.accepted_request_confirmed.other_user_for_request
      render "new.html.erb", :layout => "empty"
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
          @suggest_delivery.save(validate:false)
        elsif @user_review.req_or_sugg == "request_delivery"
          @request_delivery = RequestDelivery.find_by_id(@user_review.task_id)
          @request_delivery.sender_reviewed = true
          @request_delivery.save(validate:false)
        end
      elsif @user_review.job_type == "TRANSPORTER"
        if @user_review.req_or_sugg == "suggest_delivery"
          @suggest_delivery = SuggestDelivery.find_by_id(@user_review.task_id)
          @suggest_delivery.transporter_reviewed = true
          @suggest_delivery.save(validate:false)
        elsif @user_review.req_or_sugg == "request_delivery"
          @request_delivery = RequestDelivery.find_by_id(@user_review.task_id)
          @request_delivery.review_transporter
        end
        respond_with(@user_review, :location => root_path)
      end
    end
  end

end
