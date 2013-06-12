class StaticPagesController < ApplicationController
  def home
    @request_delivery = current_user.request_deliveries.build if signed_in?
  end

  def help
  end
  
  def contact
  end

  def about
  end
end
