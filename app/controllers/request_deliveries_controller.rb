class RequestDeliveriesController < ApplicationController
  before_filter :signed_in_user, :except => [:show, :index, :new, :create]
  before_filter :correct_user,   only: [:destroy, :edit, :update]
  respond_to :html, :js

  def show
    @request_delivery = RequestDelivery.find(params[:id])
    if !current_user.nil?
      @accepted_request = AcceptedRequest.find_by_user_id_and_request_delivery_id(current_user.id,@request_delivery.id)
    end
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
        session[:request_delivery_what] = nil
        session[:request_delivery_from] = nil
        session[:request_delivery_to] = nil
        session[:request_delivery_cost] = nil
        session[:request_delivery_currency] = nil
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
    @request_feed_items = RequestDelivery.all
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
    type = params[:type]
    if current_user != @request_delivery.user
      if type == "accept"
        current_user.request_accepts << @request_delivery
        @request_delivery.accept_request
        redirect_to :back
        flash[:accept] = "You've chosen to accept <br><b>#{@request_delivery.what}</b><br> delivery request!<br>
                                          <div class='sub_flash_text'><b>#{@request_delivery.user.name}</b>, the creator of the request, will be notified. <br>
                                          Please allow <b>#{@request_delivery.user.name}</b> some time to get back to you.</div>".html_safe
        @accepted_request = AcceptedRequest.find_by_request_delivery_id(@request_delivery.id)
        @creating_user = User.find_by_id(@request_delivery.user_id)
        @accepting_user = User.find_by_id(@accepted_request.user_id)
        NotifMailer.new_accepted_request(@creating_user,@accepting_user,@request_delivery).deliver
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

  def confirm
    @accepted_request = AcceptedRequest.find(params[:accepted_request_id])
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    @request_creator = User.find(@request_delivery.user_id)
    @confirmed_user = User.find( @accepted_request.user_id)
    if @request_creator == current_user
      if  @accepted_request.confirm_accepted_request
        @request_delivery.confirm_request
        flash[:confirm] = "You've chosen to confirm <br><b>SOMEONE</b><br>
                                          <div class='sub_flash_text'>For your request <div class='confirmed_request'><b>#{@request_delivery.what}</b><br></div></div>
                                          <div class='paypal_redirection'>You will now be redirected to
                                          <!-- PayPal Logo --><table border='0' cellpadding='10' cellspacing='0' align='center'><tr><td align='center'></td></tr><tr><td align='center'>
                                          <a href='https://www.paypal.com/webapps/mpp/paypal-popup' title='How PayPal Works'
                                          onclick='javascript:window.open('https://www.paypal.com/webapps/mpp/paypal-popup','WIPaypal','toolbar=no, location=no, directories=no, status=no,
                                          menubar=no, scrollbars=yes, resizable=yes, width=1060, height=700'); return false;'>
                                          <img src='https://www.paypalobjects.com/webstatic/mktg/logo/pp_cc_mark_37x23.jpg' border='0' alt='PayPal Logo'></a></td></tr></table><!-- PayPal Logo --></div>".html_safe
        NotifMailer.new_confirmed_request(@request_creator,@confirmed_user,@request_delivery).deliver
        redirect_to dummy_paypal_redirection_path
      end
    else
      flash[:cannot] = "Only the creator of the request can confirm it."
    end
  end

  def complete
    @accepted_request = AcceptedRequest.find(params[:accepted_request_id])
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    @request_creator = User.find(@request_delivery.user_id)
    @confirmed_user = User.find( @accepted_request.user_id)
    if @confirmed_user == current_user
      if @accepted_request.complete_accepted_request
        @request_delivery.complete_request
        flash[:complete] = "You've chosen to mark <br><b>#{@request_delivery.what}</b><br> delivery request as <br><div class='complete'><b>complete!</b></div>
                                            <div class='sub_flash_text'>A payment of <b>#{@request_delivery.cost} #{@request_delivery.currency}</b> will be transferred to you. <br></div>".html_safe
        NotifMailer.new_complete_request(@request_creator,@confirmed_user,@request_delivery).deliver
      end
    else
      flash[:cannot] = "Only the confirmed user can complete the request."
    end
    redirect_to activity_path
  end

  private

  def correct_user
    @request_delivery = current_user.request_deliveries.find_by_id(params[:id])
    redirect_to :back if @request_delivery.nil? && !current_user.try(:admin?)
  end

end