class SuggestDeliveriesController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy]
  before_filter :correct_user,   only: :destroy

  def show
    @suggest_delivery = SuggestDelivery.find(params[:id])
    @accepted_suggest = AcceptedSuggest.find_by_user_id_and_suggest_delivery_id(current_user.id,@suggest_delivery.id)
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

  def accept
    @suggest_delivery = SuggestDelivery.find(params[:id])
    type = params[:type]
    if current_user != @suggest_delivery.user
      if type == "accept"
        current_user.suggest_accepts << @suggest_delivery
        @suggest_delivery.accept_suggest
        redirect_to :back
        flash[:accept] = "You've chosen to accept <br><b>#{@suggest_delivery.size} sized items</b><br> delivery suggestion!<br>
                                              <div class='sub_flash_text'><b>#{@suggest_delivery.user.name}</b>, the creator of the suggestion, will be notified. <br>
                                              Please allow <b>#{@suggest_delivery.user.name}</b> some time to get back to you.</div>".html_safe
      elsif type == "cancel"
        current_user.suggest_accepts.delete(@suggest_delivery)
        redirect_to :back
        @suggest_delivery.cancel_suggest
        flash[:cancel] = "You've chosen to cancel the suggestion."
      else
        redirect_to :back
      end
    else
      redirect_to :back
      flash[:your_own] = "You cannot accept <br> your own delivery suggestions!".html_safe
    end
  end

  private

  def correct_user
    @suggest_delivey = current_user.suggest_deliveries.find_by_id(params[:id])
    redirect_to root_url if @suggest_delivey.nil? && !current_user.try(:admin?)
  end

end