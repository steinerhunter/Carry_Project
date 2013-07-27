class SuggestDeliveriesController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy]
  before_filter :correct_user,   only: :destroy

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

  def edit
    @suggest_delivery = SuggestDelivery.find(params[:id])
    session[:return_to] ||= request.referer
  end

  def update
    @suggest_delivery = SuggestDelivery.find(params[:id])
    if @suggest_delivery.update_attributes( params[:suggest_delivery])
      redirect_to session.delete(:return_to)
    else
      render 'edit'
    end
  end

  def destroy
    @suggest_delivery = SuggestDelivery.find(params[:id])
    @suggest_delivery.destroy
    redirect_to suggestions_path
  end

  private

  def correct_user
    @suggest_delivey = current_user.suggest_deliveries.find_by_id(params[:id])
    redirect_to root_url if @suggest_delivey.nil? && !current_user.try(:admin?)
  end

end