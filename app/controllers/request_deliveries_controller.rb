class RequestDeliveriesController < ApplicationController
  before_filter :signed_in_user, :except => [:show, :index, :new, :create]
  before_filter :correct_user,   only: [:destroy, :edit, :update]
  respond_to :html, :js

  def show
    @request_delivery = RequestDelivery.find(params[:id])
    if !current_user.nil?
      @accepted_request = AcceptedRequest.find_by_user_id_and_request_delivery_id(current_user.id,@request_delivery.id)
    end
    @facebook_authentication = Authentication.find_by_user_id(@request_delivery.user.id)
    @phone = Phone.find_by_user_id(@request_delivery.user.id)
    @my_phone = Phone.find_by_user_id(current_user.id)
    @commentable = @request_delivery
    @comments = @commentable.comments
    @comment = Comment.new
  end

  def new
    if current_user.nil?
        @request_delivery = RequestDelivery.new
    else
      @request_delivery = current_user.request_deliveries.build
    end
  end

  def create
    if current_user.nil?
      @request_delivery = RequestDelivery.new(params[:request_delivery])
      if @request_delivery.valid?
       session[:request_delivery_what] = @request_delivery.what
       session[:request_delivery_from] = @request_delivery.from
       session[:request_delivery_to] = @request_delivery.to
       session[:request_delivery_cost] = @request_delivery.cost
       session[:request_delivery_currency] = @request_delivery.currency
      end
    else
      @request_delivery = current_user.request_deliveries.build(params[:request_delivery])
      if @request_delivery.save
        flash[:request_post_created] = "Your request was added successfully!<br>
                                                      <div class='sub_flash_text'>There are some missing details though.<br>
                                                      Go to <b style=\"color:#ff9054\">Edit</b> <img src=\"../assets/edit_post_big.png\"> and add them to attract more transporters!</div>".html_safe
        respond_with(@request_delivery) do |format|
          format.html { redirect_to request_delivery_url(@request_delivery)}
        end
      end
    end

  end

  def index
    @search = RequestDelivery.search(params[:search])
    @request_feed_items = @search.all
  end

  def edit
    @request_delivery = RequestDelivery.find(params[:id])
    if @request_delivery.status == "Confirmed"
      flash[:request_post_updated] = "You cannot edit a confirmed request."
      redirect_to :back
    end
  end

  def update
    @request_delivery = RequestDelivery.find(params[:id])
    if @request_delivery.status == "Confirmed"
      flash[:request_post_updated] = "You cannot update a confirmed request."
      redirect_to :back
    else
      if @request_delivery.update_attributes( params[:request_delivery])
        @request_delivery.check_all_details
        flash[:request_post_updated] = "Your request was updated successfully!"
        respond_with(@request_delivery) do |format|
          format.html { redirect_to request_delivery_url(@request_delivery)}
        end
      end
    end
  end

  def destroy
    @request_delivery = RequestDelivery.find(params[:id])
    if @request_delivery.status == "Confirmed"
      flash[:request_post_deleted] = "You cannot delete a confirmed request."
      redirect_to :back
    else
      @request_delivery.destroy
      flash[:request_post_deleted] = "Your request was successfully deleted!"
      redirect_to requests_path
    end
  end

  def accept
    @request_delivery = RequestDelivery.find(params[:id])
    @phone = Phone.find_by_user_id(current_user.id)
    type = params[:type]
    if current_user != @request_delivery.user
      if type == "accept"
        if @phone.present?
          if @phone.verified
            current_user.request_accepts << @request_delivery
            @request_delivery.accept_request
            redirect_to :back
            flash[:accept] = "You've chosen to accept <br><b>#{@request_delivery.what}</b><br> delivery request!<br>
                                          <div class='sub_flash_text'><b>#{@request_delivery.user.name}</b>, the creator of the request, will be notified. <br>
                                          Please allow <b>#{@request_delivery.user.name}</b> some time to get back to you.</div>".html_safe
            @accepted_request = AcceptedRequest.find_all_by_request_delivery_id(@request_delivery.id).last
            @creating_user = User.find_by_id(@request_delivery.user_id)
            @accepting_user = User.find_by_id(@accepted_request.user_id)
            NotifMailer.new_accepted_request(@creating_user,@accepting_user,@request_delivery).deliver
          end
        end
      elsif type == "cancel"
        if @request_delivery.status == "Open"
          flash[:cancel] = "You cannot cancel an Open request."
          redirect_to :back
        elsif @request_delivery.status == "Confirmed"
          flash[:cancel] = "You cannot cancel a Confirmed request."
          redirect_to :back
        elsif @request_delivery.status == "Complete"
          flash[:cancel] = "You cannot cancel a Complete request."
          redirect_to :back
        else
          current_user.request_accepts.delete(@request_delivery)
          redirect_to :back
          @request_delivery.cancel_request
          flash[:cancel] = "You've chosen to cancel the request."
        end
      else
        redirect_to :back
      end
    else
      redirect_to :back
      flash[:your_own] = "You cannot accept <br> your own delivery requests!".html_safe
    end
  end

  def pre_confirm
    @accepted_request = AcceptedRequest.find_by_id(params[:accepted_request_id])
    @request_delivery = RequestDelivery.find_by_id(@accepted_request.request_delivery_id)
    render "pre_confirm.html.erb", :layout => false
  end

  def pre_cancel
    @accepted_request = AcceptedRequest.find_by_id(params[:accepted_request_id])
    render "pre_cancel.html.erb", :layout => false
  end

  def pre_complete
    @accepted_request = AcceptedRequest.find_by_id(params[:accepted_request_id])
    @request_delivery = RequestDelivery.find_by_id(@accepted_request.request_delivery_id)
    render "pre_complete.html.erb", :layout => false
  end

  def confirm
    @accepted_request = AcceptedRequest.find(params[:accepted_request_id])
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    @request_creator = User.find(@request_delivery.user_id)
    @confirmed_user = User.find( @accepted_request.user_id)
    if @request_creator == current_user
        #NotifMailer.new_confirmed_request(@request_creator,@confirmed_user,@request_delivery).deliver
        redirect_to :controller => 'payments',
                                  :action => 'checkout',
                                  :req_or_sugg => "request_delivery",
                                  :task_creator_id => @request_creator.id,
                                  :confirmed_user_id => @confirmed_user.id,
                                  :task_id => @request_delivery.id,
                                  :accepted_task_id => @accepted_request.id
    else
      flash[:cannot] = "Only the creator of the request can confirm it."
    end
  end

  def complete
    @accepted_request = AcceptedRequest.find(params[:accepted_request_id])
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    @request_creator = User.find(@request_delivery.user_id)
    @confirmed_user = User.find( @accepted_request.user_id)
    @request_payment = RequestPayment.find_by_request_delivery_id(@request_delivery.id)
    if @confirmed_user == current_user && @request_payment.approved
        #NotifMailer.new_complete_request(@request_creator,@confirmed_user,@request_delivery).deliver
        redirect_to :controller => 'payments',
                                  :action => 'execute',
                                  :req_or_sugg => "request_delivery",
                                  :task_creator_id => @request_creator.id,
                                  :confirmed_user_id => @confirmed_user.id,
                                  :task_id => @request_delivery.id,
                                  :accepted_task_id => @accepted_request.id
    else
      redirect_to activity_url
    end
  end

  private

  def correct_user
    @request_delivery = current_user.request_deliveries.find_by_id(params[:id])
    redirect_to :back if @request_delivery.nil? && !current_user.try(:admin?)
  end

end