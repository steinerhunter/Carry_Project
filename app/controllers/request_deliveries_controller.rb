class RequestDeliveriesController < ApplicationController
  before_filter :signed_in_user, :except => [:show, :index_takers, :index_transporters, :new, :create]
  before_filter :correct_user,   only: [:destroy, :update]
  respond_to :html, :js

  def show
    @request_delivery = RequestDelivery.find(params[:id])
    if @request_delivery.status != "Open" && @request_delivery.status != "Unpublished"
      @taking_user = @request_delivery.confirmed_taker
    end
    if current_user.nil?
      if @request_delivery.status != "Open" && @request_delivery.status != "WaitingForTransporter" && @request_delivery.status != "Pending Confirmation"
        @non_involved_user = true
      end
    else
      @my_taken_giveaway = TakenGiveaway.find_by_user_id_and_request_delivery_id(current_user.id,@request_delivery.id)
      @any_taken_giveaway = TakenGiveaway.find_by_request_delivery_id(@request_delivery.id)
      @accepted_request = AcceptedRequest.find_by_user_id_and_request_delivery_id(current_user.id,@request_delivery.id)
      @someone_is_confirmed = AcceptedRequest.find_by_request_delivery_id_and_confirmed(@request_delivery.id,true)
      if @someone_is_confirmed
        @transporter = @request_delivery.accepted_request_confirmed.other_user_for_request
      end
      @my_phone = Phone.find_by_user_id(current_user.id)

      @show_bounty = (@request_delivery.status == "WaitingForTransporter" ||
          @request_delivery.status == "Pending Confirmation" ||
          @request_delivery.status == "Confirmed" ||
          @request_delivery.status == "Complete" ||
          @request_delivery.status == "TransporterReviewed") &&
          @request_delivery.user != current_user &&
          @taking_user != current_user

      @non_editable = @request_delivery.status == "ReceiverConfirmed" ||
          @request_delivery.status == "WaitingForTransporter" ||
          @request_delivery.status == "Pending Confirmation" ||
          @request_delivery.status == "Confirmed" ||
          @request_delivery.status == "Complete" ||
          @request_delivery.status == "TransporterReviewed"

      @after_delivery = @request_delivery.status == "Complete" ||
          @request_delivery.status == "TransporterReviewed"

      @big_sender_receiver = @request_delivery.status == "ReceiverConfirmed" ||
          @request_delivery.status == "Confirmed"

      @my_giveaway_accepted = AcceptedRequest.find_all_by_request_delivery_id(@request_delivery.id)

      if @request_delivery.status != "Open" &&
          @request_delivery.status != "WaitingForTransporter" &&
          @request_delivery.status != "Pending Confirmation" &&
          @request_delivery.user != current_user &&
          @transporter != current_user &&
          @any_taken_giveaway.present? &&
          @any_taken_giveaway.taken &&
          @any_taken_giveaway.user_id != current_user.id
        @non_involved_user = true
      end
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
    render "new.html.erb", :layout => "empty"
  end

  def create
    if current_user.nil?
      @request_delivery = RequestDelivery.new(params[:request_delivery])
      if @request_delivery.valid?
        session[:request_delivery_what] = @request_delivery.what
        session[:request_delivery_from] = @request_delivery.from
        session[:request_delivery_size] = @request_delivery.size
        session[:request_delivery_attachment] = @request_delivery.attachment
      end
    else
      @phone = Phone.find_by_user_id(current_user.id)
      @request_delivery = current_user.request_deliveries.build(params[:request_delivery])
      if @request_delivery.save
        @request_delivery.set_giver
        if @phone.present?
          @request_delivery.set_giver_phone
        end
        @request_delivery.publish
        flash[:success] = "Thank you!<br>
                                              <div class='sub_flash_text'>Your Giveaway was successfully added to our lists. <br>
                                              Perhaps some of your friends might be interested in it?<br><br>
                                             <a href=#{@request_delivery.facebook_share_giveaway_owner} target='_blank' class='facebook_share'>Share your Giveaway on Facebook!</a></div>".html_safe
        respond_with(@request_delivery) do |format|
          format.html { redirect_to request_delivery_url(@request_delivery)}
        end
      end
    end
  end

  def index_takers
    @open_requests = RequestDelivery.where("status = ?","Open")
    @search = @open_requests.search(params[:search])
    @request_feed_items = @search.all.sort_by { |a| a.has_all_details ? 0 : 1}
  end

  def index_transporters
    @transporter_requests = RequestDelivery.where("status = ? OR status = ?","WaitingForTransporter","Pending Confirmation")
    @search = @transporter_requests.search(params[:search])
    @request_feed_items = @search.all.sort_by { |a| a.has_all_details ? 0 : 1}
  end

  def edit_cost
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    if @request_delivery.user == current_user
      render "edit_cost.html.erb", :layout => false
    end
  end

  def edit_what
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    if @request_delivery.user == current_user
      render "edit_what.html.erb", :layout => "empty"
    end
  end

  def edit_picture
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    if @request_delivery.user == current_user
      render "edit_picture.html.erb", :layout => "empty"
    end
  end

  def edit_from
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    if @request_delivery.user == current_user
      render "edit_from.html.erb", :layout => "empty"
    end
  end

  def edit_delivery
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    @my_taken_giveaway = TakenGiveaway.find_by_user_id_and_request_delivery_id(current_user.id,@request_delivery.id)
    @taking_user = User.find_by_id(@my_taken_giveaway.user_id)
    if @taking_user == current_user
      render "edit_delivery.html.erb", :layout => "empty"
    end
  end

  def edit_to
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    @my_taken_giveaway = TakenGiveaway.find_by_user_id_and_request_delivery_id(current_user.id,@request_delivery.id)
    @taking_user = User.find_by_id(@my_taken_giveaway.user_id)
    if @taking_user == current_user
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
    @my_taken_giveaway = TakenGiveaway.find_by_user_id_and_request_delivery_id(current_user.id,@request_delivery.id)
    if @request_delivery.status == "Open" && @request_delivery.user != current_user
      flash[:failure] = "Sorry!<br><div class='sub_flash_text'>Only the owner of this giveaway can edit its details.</div>".html_safe
      redirect_to :back
    elsif @my_taken_giveaway.present? && @request_delivery.status == "Taken" && @my_taken_giveaway.user_id != current_user.id
      flash[:failure] = "Sorry!<br><div class='sub_flash_text'>Someone has decided to take this giveaway, so you cannot edit its details.</div>".html_safe
      redirect_to :back
    else
      @request_delivery.assign_attributes( params[:request_delivery])
      if @request_delivery.to_changed?
        @request_delivery.calculate_distance
        @request_delivery.set_cost
        @request_delivery.update_attribute(:delivery_type, nil)
      end
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
    if @request_delivery.status != "Open" && @request_delivery.status != "Unpublished"
      flash[:failure] = "Sorry!<br><div class='sub_flash_text'>You cannot delete your giveaway since someone has already accepted it.</div>".html_safe
      redirect_to :back
    else
      @request_delivery.destroy
      flash[:success] = "Thank you!<br><div class='sub_flash_text'>Your giveaway has been successfully deleted.</div>".html_safe
      redirect_to giveaways_path
    end
  end

  def take
    @request_delivery = RequestDelivery.find(params[:id])
    @phone = Phone.find_by_user_id(current_user.id)
    type = params[:type]
    if current_user != @request_delivery.user
      if type == "take" && @request_delivery.status == "Open"
        if @phone.present?
          if @phone.verified
            current_user.request_takes << @request_delivery
            @request_delivery.take_request
            redirect_to :back
            flash[:success] = "Thank you!<br>
                                              <div class='sub_flash_text'>You've chosen to take <b style=\"color:#1a2cff\">#{@request_delivery.what}</b> item giveaway.<br>
                                              <b style=\"color:#1a2cff\">#{@request_delivery.user.name}</b>, the giving person, will be notified. <br>
                                              In order to proceed, there are some details that we need.<br>
                                              <b style=\"color:#ff9054\">Add</b> <img src=\"../assets/missing_detail.png\"> them and <b style=\"color:#1a2cff\">#{@request_delivery.what}</b> is coming your way!</div>".html_safe
            @taken_giveaway = TakenGiveaway.find_all_by_request_delivery_id(@request_delivery.id).last
            @creating_user = User.find_by_id(@request_delivery.user_id)
            @taking_user = User.find_by_id(@taken_giveaway.user_id)
            if Rails.env.production?
              NotifMailer.new_taken_giveaway(@creating_user,@taking_user,@request_delivery).deliver
            end
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
          current_user.request_takes.delete(@request_delivery)
          redirect_to :back
          @request_delivery.untake_request
          flash[:success] = "Thank you!<br><div class='sub_flash_text'>You've decided not to take this giveaway.</div>".html_safe
        end
      else
        redirect_to :back
      end
    else
      redirect_to :back
      flash[:failure] = "Sorry!<br><div class='sub_flash_text'>You cannot take your own giveaways.</div>".html_safe
    end
  end

  def another_taker
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    @creating_user = @request_delivery.user
    @taking_user = @request_delivery.confirmed_taker
    if @request_delivery.user == current_user
      if Rails.env.production?
        NotifMailer.another_user(@creating_user,@taking_user,@request_delivery).deliver
      end
      @request_delivery.confirmed_taker.request_takes.delete(@request_delivery)
      redirect_to :back
      @request_delivery.untake_request
      flash[:success] = "Thank you!<br><div class='sub_flash_text'>You've decided to let someone else have your Giveaway.</div>".html_safe
    else
      redirect_to :back
      flash[:failure] = "Sorry!<br><div class='sub_flash_text'>You cannot do that.</div>".html_safe
    end
  end

  def get_the_item
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    @taken_giveaway = TakenGiveaway.find_by_request_delivery_id(@request_delivery.id)
    @creating_user = @request_delivery.user
    @taking_user = User.find_by_id(@taken_giveaway.user_id)
    if @taking_user == current_user && @request_delivery.status == "Taken" && @request_delivery.has_all_details
      if @request_delivery.delivery_type == "senddme" && @request_delivery.cost.to_i > 0
        @request_delivery.wait_for_transporter
        flash[:success] = "Thank you!<br><div class='sub_flash_text'>You're now confirmed for this giveaway.<br>
        Now it's time to set you up with a Transporter.</div>".html_safe
        flash[:success] = "Thank you!<br>
                                             <div class='sub_flash_text'>You're now confirmed for this giveaway.<br>
                                              Perhaps some of your friends can pick it up for you?<br><br>
                                             <a href=#{@request_delivery.facebook_share_pick_up_owner} target='_blank' class='facebook_share'>Find Pick Up on Facebook!</a></div>".html_safe
        if Rails.env.production?
          NotifMailer.new_taken_confirmed_senddme(@creating_user,@taking_user,@request_delivery).deliver
        end
      elsif @request_delivery.delivery_type == "myself"
        @request_delivery.get_the_item
        flash[:success] = "Thank you!<br><div class='sub_flash_text'>You're now confirmed for this giveaway.<br>
        You can call <b style=\"color:#1a2cff\">#{@request_delivery.user.name}</b>, the giving person, and set a time for a pick up.</div>".html_safe
        if Rails.env.production?
          NotifMailer.new_taken_confirmed_self(@creating_user,@taking_user,@request_delivery).deliver
        end
      end
    end
    redirect_to request_delivery_url(@request_delivery)
  end

  def got_the_item
    @request_delivery = RequestDelivery.find(params[:request_delivery_id])
    @taken_giveaway = TakenGiveaway.find_by_request_delivery_id(@request_delivery.id)
    @taking_user = User.find_by_id(@taken_giveaway.user_id)
    if @taking_user == current_user && @request_delivery.status == "ReceiverConfirmed" && @request_delivery.has_all_details
      @request_delivery.got_the_item
    end
    redirect_to :back
  end

  def accept
    @request_delivery = RequestDelivery.find(params[:id])
    @taken_giveaway = TakenGiveaway.find_all_by_request_delivery_id(@request_delivery.id).last
    @taking_user = User.find_by_id(@taken_giveaway.user_id)
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
                                              <div class='sub_flash_text'>You've chosen to accept <b style=\"color:#1a2cff\">#{@request_delivery.what}</b> pick up.<br>
                                              <b style=\"color:#1a2cff\">#{@taking_user.name}</b>, the person interested in the pick up, will be notified. <br>
                                              Now <b style=\"color:#1a2cff\">#{@taking_user.name}</b> must confirm you.</div>".html_safe
            @accepted_request = AcceptedRequest.find_all_by_request_delivery_id(@request_delivery.id).last
            @creating_user = User.find_by_id(@request_delivery.user_id)
            @accepting_user = User.find_by_id(@accepted_request.user_id)
            if Rails.env.production?
              NotifMailer.new_accepted_request(@taking_user,@accepting_user,@request_delivery).deliver
            end
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
          @request_delivery.unaccept_request
          flash[:success] = "Thank you!<br><div class='sub_flash_text'>You've chosen not to pick up this item.</div>".html_safe
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
    @confirmed_taker = @request_delivery.confirmed_taker
    @confirmed_user = User.find( @accepted_request.user_id)
    if @confirmed_taker == current_user && @phone.present? && @phone.verified
      redirect_to :controller => 'payments',
                  :action => 'checkout',
                  :req_or_sugg => "request_delivery",
                  :task_creator_id => @confirmed_taker.id,
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
    @taken_giveaway = current_user.request_takes.find_by_id(params[:id])
    @waiting_for_transporter = RequestDelivery.find_by_id_and_status(params[:id],"WaitingForTransporter")
    redirect_to :back if @request_delivery.nil? && @taken_giveaway.nil? && @waiting_for_transporter.nil? && !current_user.try(:admin?)
  end

end