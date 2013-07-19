class RequestDeliveriesController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy]

  def show
    @request_delivery = RequestDelivery.find(params[:id])
    @commentable = @request_delivery
    @comments = @commentable.comments
    @comment = Comment.new
  end

  def new
    @request_delivery = current_user.request_deliveries.build if signed_in?
  end

  def create
    @request_delivery = current_user.request_deliveries.build(params[:request_delivery])
    if @request_delivery.save
      flash[:success] = "Delivery Request created!"
      redirect_to root_url
    else
      render 'static_pages/home'
    end
  end

  def index
    @request_feed_items = RequestDelivery.all
  end

  def destroy
  end
end