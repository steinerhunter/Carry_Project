class SuggestDeliveriesController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy]

  def show
    @suggest_delivery = SuggestDelivery.find(params[:id])
    @commentable = @suggest_delivery
    @comments = @commentable.comments
    @comment = Comment.new
  end

  def new
    @suggest_delivery = current_user.suggest_deliveries.build if signed_in?
  end

  def create
    @suggest_delivery = current_user.suggest_deliveries.build(params[:suggest_delivery])
    if @suggest_delivery.save
      flash[:success] = "Delivery Suggestion created!"
      redirect_to root_url
    else
      render 'static_pages/home'
    end
  end

  def index
    @suggest_feed_items = SuggestDelivery.all
  end
  
  def destroy
  end
end