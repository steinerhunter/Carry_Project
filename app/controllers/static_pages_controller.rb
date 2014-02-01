class StaticPagesController < ApplicationController
  before_filter :signed_in_user, :only => :dummy_paypal_redirection

  def home
    @open_requests = RequestDelivery.where("status = ?","Open")
    @search = @open_requests.search(params[:search])
    @request_feed_items = @search.all.sort_by { |a| a.has_all_details ? 0 : 1}
  end

  def privacy_policy
  end

  def faq
    if !current_user.try(:admin?)
      redirect_to root_path
    end
  end

  def terms_of_use
  end

end