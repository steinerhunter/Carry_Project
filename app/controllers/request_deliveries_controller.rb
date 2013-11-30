class RequestDeliveriesController < ApplicationController
  before_filter :signed_in_user, :except => [:show, :index, :new, :create]
  before_filter :correct_user,   only: [:destroy, :update]
  respond_to :html, :js

  def show
    @request_delivery = RequestDelivery.find(params[:id])
    if !current_user.nil?
      @accepted_request = AcceptedRequest.find_by_user_id_and_request_delivery_id(current_user.id,@request_delivery.id)
      @my_phone = Phone.find_by_user_id(current_user.id)
    end
    @facebook_authentication = Authentication.find_by_user_id(@request_delivery.user.id)
    @phone = Phone.find_by_user_id(@request_delivery.user.id)
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
        flash[:success] = "Thank you!<br>
                                              <div class='sub_flash_text'>Your delivery request was successfully added to our lists. <br>
                                              There are some more details to add though.<br>
                                              <b style=\"color:#ff9054\">Add</b> <img src=\"../assets/missing_detail.png\"> all details and get priority in our lists!</div>".html_safe
        respond_with(@request_delivery) do |format|
          format.html { redirect_to request_delivery_url(@request_delivery)}
        end
      end
    end

  end

  def index
    @search = RequestDelivery.search(params[:search])
    @request_feed_items = @search.all.sort_by { |a| a.has_all_details ? 0 : 1}
  end

  def edit_cost
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    if @request_delivery.user == current_user
      render "edit_cost.html.erb", :layout => false
    end
  end

  def edit_from
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    if @request_delivery.user == current_user
      render "edit_from.html.erb", :layout => "empty"
    end
  end

  def edit_to
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    if @request_delivery.user == current_user
      render "edit_to.html.erb", :layout => "empty"
    end
  end

  def edit_size
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    if @request_delivery.user == current_user
      render "edit_size.html.erb", :layout => false
    end
  end

  def edit_due_date
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    if @request_delivery.user == current_user
      render "edit_due_date.html.erb", :layout => "empty"
    end
  end

  def edit_sending_person
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    if @request_delivery.user == current_user
      render "edit_sending_person.html.erb", :layout => false
    end
  end

  def edit_receiving_person
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    if @request_delivery.user == current_user
      render "edit_receiving_person.html.erb", :layout => false
    end
  end

  def update
    @request_delivery = RequestDelivery.find(params[:id])
    if @request_delivery.status != "Open"
      flash[:failure] = "Sorry!<br><div class='sub_flash_text'>You cannot edit the details of your request since someone has already accepted it.</div>".html_safe
      redirect_to :back
    else
      if @request_delivery.update_attributes( params[:request_delivery])
        @request_delivery.check_all_details
        flash[:success] = "Thank you!<br><div class='sub_flash_text'>Your details were successfully updated.</div>".html_safe
        respond_with(@request_delivery) do |format|
          format.html { redirect_to request_delivery_url(@request_delivery)}
        end
      end
    end
  end

  def destroy
    @request_delivery = RequestDelivery.find(params[:id])
    if @request_delivery.status != "Open"
      flash[:failure] = "Sorry!<br><div class='sub_flash_text'>You cannot delete your delivery request since someone has already accepted it.</div>".html_safe
      redirect_to :back
    else
      @request_delivery.destroy
      flash[:success] = "Thank you!<br><div class='sub_flash_text'>Your delivery request has been successfully deleted.</div>".html_safe
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
            flash[:success] = "Thank you!<br>
                                              <div class='sub_flash_text'>You've chosen to accept <b>#{@request_delivery.what}</b> delivery request.<br>
                                              <b>#{@request_delivery.user.name}</b>, the creator of the request, will be notified. <br>
                                              Now <b>#{@request_delivery.user.name}</b> must confirm you.</div>".html_safe
            @accepted_request = AcceptedRequest.find_all_by_request_delivery_id(@request_delivery.id).last
            @creating_user = User.find_by_id(@request_delivery.user_id)
            @accepting_user = User.find_by_id(@accepted_request.user_id)
            NotifMailer.new_accepted_request(@creating_user,@accepting_user,@request_delivery).deliver
          end
        end
      elsif type == "cancel"
        if @request_delivery.status == "Open"
          flash[:failure] = "Sorry!<br><div class='sub_flash_text'>You cannot cancel an Open request.</div>".html_safe
          redirect_to :back
        elsif @request_delivery.status == "Confirmed"
          flash[:failure] = "Sorry!<br><div class='sub_flash_text'>You cannot cancel a Confirmed request.</div>".html_safe
          redirect_to :back
        elsif @request_delivery.status == "Complete"
          flash[:failure] = "Sorry!<br><div class='sub_flash_text'>You cannot cancel a Complete request.</div>".html_safe
          redirect_to :back
        else
          current_user.request_accepts.delete(@request_delivery)
          redirect_to :back
          @request_delivery.cancel_request
          flash[:success] = "Thank you!<br><div class='sub_flash_text'>You've chosen to cancel your acceptance of the request.</div>".html_safe
        end
      else
        redirect_to :back
      end
    else
      redirect_to :back
      flash[:failure] = "Sorry!<br><div class='sub_flash_text'>You cannot accept your own delivery requests.</div>".html_safe
    end
  end

  def pre_confirm
    @phone = Phone.find_by_user_id(current_user.id)
    @accepted_request = AcceptedRequest.find_by_id(params[:accepted_request_id])
    @request_delivery = RequestDelivery.find_by_id(@accepted_request.request_delivery_id)
    if @phone.present? && @phone.verified
      render "pre_confirm.html.erb", :layout => false
    else
      redirect_to activity_path
    end
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
    @phone = Phone.find_by_user_id(current_user.id)
    @accepted_request = AcceptedRequest.find(params[:accepted_request_id])
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    @request_creator = User.find(@request_delivery.user_id)
    @confirmed_user = User.find( @accepted_request.user_id)
    if @request_creator == current_user && @phone.present? && @phone.verified
      if Rails.env.production?
        NotifMailer.new_confirmed_request(@request_creator,@confirmed_user,@request_delivery).deliver
      end
      redirect_to :controller => 'payments',
                  :action => 'checkout',
                  :req_or_sugg => "request_delivery",
                  :task_creator_id => @request_creator.id,
                  :confirmed_user_id => @confirmed_user.id,
                  :task_id => @request_delivery.id,
                  :accepted_task_id => @accepted_request.id
    else
      redirect_to activity_path
    end
  end

  def complete
    @accepted_request = AcceptedRequest.find(params[:accepted_request_id])
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    @request_creator = User.find(@request_delivery.user_id)
    @confirmed_user = User.find( @accepted_request.user_id)
    @request_payment = RequestPayment.find_by_request_delivery_id(@request_delivery.id)
    if @confirmed_user == current_user && @request_payment.approved
      flash[:success] = "Great!<br><div class='sub_flash_text'>You've chosen to mark <b>#{@request_delivery.what}</b> delivery request as complete.</div>".html_safe
      if Rails.env.production?
        NotifMailer.new_complete_request(@request_creator,@confirmed_user,@request_delivery).deliver
      end
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