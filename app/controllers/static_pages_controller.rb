class StaticPagesController < ApplicationController
  before_filter :signed_in_user, :only => :dummy_paypal_redirection

  def home
  end

  def how_it_works
  end

  def dummy_paypal_redirection
    render "dummy_paypal_redirection.html.erb", :layout => false
  end

  def privacy_policy
  end

  def terms_of_use
  end

  def website_disclaimer
  end

  def earnings_disclaimer
  end

end