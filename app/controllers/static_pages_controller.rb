class StaticPagesController < ApplicationController
  before_filter :signed_in_user, :only => :dummy_paypal_redirection

  def home
  end

  def privacy_policy
  end

  def terms_of_use
  end

end