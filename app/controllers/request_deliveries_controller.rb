class RequestDeliveriesController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy]
  before_filter :correct_user,   only: :destroy

  def show
    @request_delivery = RequestDelivery.find(params[:id])
    @accepted_request = AcceptedRequest.find_by_user_id_and_request_delivery_id(current_user.id,@request_delivery.id)
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

  def edit
    @request_delivery = RequestDelivery.find(params[:id])
    session[:return_to] ||= request.referer
  end

  def update
    @request_delivery = RequestDelivery.find(params[:id])
    if @request_delivery.update_attributes( params[:request_delivery])
      redirect_to session.delete(:return_to)
    else
      render 'edit'
    end
  end

  def destroy
    @request_delivery = RequestDelivery.find(params[:id])
    @request_delivery.destroy
    redirect_to requests_path
  end

  def accept
    @request_delivery = RequestDelivery.find(params[:id])
    type = params[:type]
    if current_user != @request_delivery.user
      if type == "accept"
        current_user.accepts << @request_delivery
        redirect_to :back
        flash[:accept] = "You've chosen to accept <br><b>#{@request_delivery.what}</b><br> delivery request!<br>
                                              <div class='sub_flash_text'><b>#{@request_delivery.user.name}</b>, the creator of the request, will be notified. <br>
                                              Please allow <b>#{@request_delivery.user.name}</b> some time to get back to you.</div>".html_safe
      elsif type == "cancel"
        current_user.accepts.delete(@request_delivery)
        redirect_to :back
        flash[:cancel] = "You've chosen to cancel the request."
      else
        redirect_to :back
      end
    else
      redirect_to :back
      flash[:your_own] = "You cannot accept <br> your own delivery requests!".html_safe
    end
  end

  private

  def correct_user
    @request_delivey = current_user.request_deliveries.find_by_id(params[:id])
    redirect_to root_url if @request_delivey.nil? && !current_user.try(:admin?)
  end

end