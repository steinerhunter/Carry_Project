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
      respond_with(@user_review, :location => root_path)
    end
  end

end