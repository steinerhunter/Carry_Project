class StaticPagesController < ApplicationController
  before_filter :signed_in_user, :only => :dummy_paypal_redirection

  def home
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