class ActivitiesController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy]

  def index
    @request_feed_items = current_user.user_request_feed
    @suggest_feed_items = current_user.user_suggest_feed
    @accepted_requests = AcceptedRequest.where("user_id = ?",current_user.id)
    @accepted_requests_id = @accepted_requests.pluck(:request_delivery_id)
    @accepted_request_feed_items = RequestDelivery.find_all_by_id(@accepted_requests_id)
  end

end
