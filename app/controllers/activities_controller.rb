class ActivitiesController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy]

  def index
    @users = User.all
    @phone = Phone.find_by_user_id(current_user.id)

    @request_feed_items = current_user.user_request_feed
    @my_accepted_requests = AcceptedRequest.where("user_id = ?",current_user.id)
    @my_accepted_requests_id = @my_accepted_requests.pluck(:request_delivery_id)
    @my_accepted_request_feed_items = RequestDelivery.find_all_by_id(@my_accepted_requests_id)

    @my_requests = RequestDelivery.where("user_id = ?",current_user.id)
    @my_requests_id = @my_requests.pluck(:id)
    @my_requests_accepted = AcceptedRequest.find_all_by_request_delivery_id(@my_requests_id)

    @suggest_feed_items = current_user.user_suggest_feed
    @my_accepted_suggests = AcceptedSuggest.where("user_id = ?",current_user.id)
    @my_accepted_suggests_id = @my_accepted_suggests.pluck(:suggest_delivery_id)
    @my_accepted_suggest_feed_items = SuggestDelivery.find_all_by_id(@my_accepted_suggests_id)

    @my_suggests = SuggestDelivery.where("user_id = ?",current_user.id)
    @my_suggests_id = @my_suggests.pluck(:id)
    @my_suggests_accepted = AcceptedSuggest.find_all_by_suggest_delivery_id(@my_suggests_id)

  end
end
