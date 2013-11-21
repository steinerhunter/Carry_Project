class SuggestDeliveriesController < ApplicationController
  before_filter :signed_in_user, :except => [:show, :index, :new, :create]
  before_filter :correct_user,   only: [:destroy, :update]
  respond_to :html, :js

  def show
    @suggest_delivery = SuggestDelivery.find(params[:id])
    if !current_user.nil?
      @accepted_suggest = AcceptedSuggest.find_by_user_id_and_suggest_delivery_id(current_user.id,@suggest_delivery.id)
      @my_phone = Phone.find_by_user_id(current_user.id)
    end
    @facebook_authentication = Authentication.find_by_user_id(@suggest_delivery.user.id)
    @phone = Phone.find_by_user_id(@suggest_delivery.user.id)
    @commentable = @suggest_delivery
    @comments = @commentable.comments
    @comment = Comment.new
  end

  def new
    if current_user.nil?
      @suggest_delivery = SuggestDelivery.new
    else
      @suggest_delivery = current_user.suggest_deliveries.build
    end
  end

  def create
    if current_user.nil?
      @suggest_delivery = SuggestDelivery.new(params[:suggest_delivery])
      if @suggest_delivery.valid?
        session[:suggest_delivery_size] = @suggest_delivery.size
        session[:suggest_delivery_from] = @suggest_delivery.from
        session[:suggest_delivery_to] = @suggest_delivery.to
        session[:suggest_delivery_cost] = @suggest_delivery.cost
        session[:suggest_delivery_currency] = @suggest_delivery.currency
      end
    else
      @suggest_delivery = current_user.suggest_deliveries.build(params[:suggest_delivery])
      if @suggest_delivery.save
        flash[:suggest_post_created] = "Your suggestion was added successfully!<br>
                                                      <div class='sub_flash_text'>There are some missing details though.<br>
                                                      Go to <b style=\"color:#ff9054\">Edit</b> <img src=\"../assets/edit_post_big.png\"> and add them to attract more senders!</div>".html_safe
        respond_with(@suggest_delivery) do |format|
          format.html { redirect_to suggest_delivery_url(@suggest_delivery)}
        end
      end
    end
  end

  def index
    #@suggest_feed_items = SuggestDelivery.all
    @search = SuggestDelivery.search(params[:search])
    @suggest_feed_items = @search.all
  end

  def edit_cost
    @suggest_delivery = SuggestDelivery.find(params[:suggest_delivery_id])
    if @suggest_delivery.user == current_user
      render "edit_cost.html.erb", :layout => false
    end
  end

  def edit_from
    @suggest_delivery = SuggestDelivery.find(params[:suggest_delivery_id])
    if @suggest_delivery.user == current_user
      render "edit_from.html.erb", :layout => false
    end
  end

  def edit_to
    @suggest_delivery = SuggestDelivery.find(params[:suggest_delivery_id])
    if @suggest_delivery.user == current_user
      render "edit_to.html.erb", :layout => false
    end
  end

  def edit_due_date
    @suggest_delivery = SuggestDelivery.find(params[:suggest_delivery_id])
    if @suggest_delivery.user == current_user
      render "edit_due_date.html.erb", :layout => false
    end
  end

  def edit_freq
    @suggest_delivery = SuggestDelivery.find(params[:suggest_delivery_id])
    if @suggest_delivery.user == current_user
      render "edit_freq.html.erb", :layout => false
    end
  end

  def update
    @suggest_delivery = SuggestDelivery.find(params[:id])
    if @suggest_delivery.status == "Confirmed"
      flash[:request_post_updated] = "Sorry!<br>
                                                      <div class='sub_flash_text'>You cannot edit the details of your request, <br>
                                                      Since someone has already accepted it.</div>".html_safe
      redirect_to :back
    else
      if @suggest_delivery.update_attributes( params[:suggest_delivery])
        @suggest_delivery.check_all_details
        flash[:request_post_updated] = "Thank you!<br>
                                                      <div class='sub_flash_text'>Your details were successfully updated.</div>".html_safe
        respond_with(@suggest_delivery) do |format|
          format.html { redirect_to suggest_delivery_url(@suggest_delivery)}
        end
      end
    end
  end

  def destroy
    @suggest_delivery = SuggestDelivery.find(params[:id])
    if @suggest_delivery.status == "Confirmed"
      flash[:suggest_post_deleted] = "You cannot delete a confirmed suggestion."
      redirect_to :back
    else
      @suggest_delivery.destroy
      flash[:suggest_post_deleted] = "Your suggestion was successfully deleted!"
      redirect_to suggestions_path
    end
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
        @accepted_suggest = AcceptedSuggest.find_by_suggest_delivery_id(@suggest_delivery.id)
        @creating_user = User.find_by_id(@suggest_delivery.user_id)
        @accepting_user = User.find_by_id(@accepted_suggest.user_id)
        NotifMailer.new_accepted_suggest(@creating_user,@accepting_user,@suggest_delivery).deliver
      elsif type == "cancel"
        if @suggest_delivery.status == "Confirmed"
          flash[:cancel] = "You cannot cancel a confirmed suggestion."
          redirect_to :back
        else
          current_user.suggest_accepts.delete(@suggest_delivery)
          redirect_to :back
          @suggest_delivery.cancel_suggest
          flash[:cancel] = "You've chosen to cancel the suggestion."
        end
      else
        redirect_to :back
      end
    else
      redirect_to :back
      flash[:your_own] = "You cannot accept <br> your own delivery suggestions!".html_safe
    end
  end

  def confirm
    @phone = Phone.find_by_user_id(current_user.id)
    @accepted_suggest = AcceptedSuggest.find(params[:accepted_suggest_id])
    @suggest_delivery = SuggestDelivery.find(params[:suggest_delivery_id])
    @suggest_creator = User.find(@suggest_delivery.user_id)
    @confirmed_user = User.find( @accepted_suggest.user_id)
    if @suggest_creator == current_user  && @phone.present? && @phone.verified
      if @accepted_suggest.save
        @accepted_suggest.confirm_accepted_suggest
        @suggest_delivery.confirm_suggest
        flash[:confirm] = "You've chosen to confirm <br><b>#{@confirmed_user.name}</b><br>
                                          <div class='sub_flash_text'>For your suggestion <div class='confirmed_suggest'><b>Transport #{@suggest_delivery.size} sized items</b><br></div></div>".html_safe
        NotifMailer.new_confirmed_suggest(@suggest_creator,@confirmed_user,@suggest_delivery).deliver
      end
    end
    redirect_to activity_path
  end

  def pre_authorize
    @accepted_suggest = AcceptedSuggest.find_by_id(params[:accepted_suggest_id])
    @suggest_delivery = SuggestDelivery.find_by_id(@accepted_suggest.suggest_delivery_id)
    render "pre_authorize.html.erb", :layout => false
  end

  def pre_cancel
    @accepted_suggest = AcceptedSuggest.find_by_id(params[:accepted_suggest_id])
    render "pre_cancel.html.erb", :layout => false
  end

  def pre_complete
    @accepted_suggest = AcceptedSuggest.find_by_id(params[:accepted_suggest_id])
    @suggest_delivery = SuggestDelivery.find_by_id(@accepted_suggest.suggest_delivery_id)
    render "pre_complete.html.erb", :layout => false
  end

  def authorize
    @accepted_suggest = AcceptedSuggest.find(params[:accepted_suggest_id])
    @suggest_delivery = SuggestDelivery.find(params[:suggest_delivery_id])
    @suggest_creator = User.find(@suggest_delivery.user_id)
    @confirmed_user = User.find( @accepted_suggest.user_id)
    if @confirmed_user == current_user
      #NotifMailer.new_confirmed_suggest(@suggest_creator,@confirmed_user,@suggest_delivery).deliver
      redirect_to :controller => 'payments',
                  :action => 'checkout',
                  :req_or_sugg => "suggest_delivery",
                  :task_creator_id => @suggest_creator.id,
                  :confirmed_user_id => @confirmed_user.id,
                  :task_id => @suggest_delivery.id,
                  :accepted_task_id => @accepted_suggest.id
    else
      flash[:cannot] = "Only the creator of the suggestion can confirm it."
    end
  end

  def complete
    @accepted_suggest = AcceptedSuggest.find(params[:accepted_suggest_id])
    @suggest_delivery = SuggestDelivery.find(params[:suggest_delivery_id])
    @suggest_creator = User.find(@suggest_delivery.user_id)
    @suggest_payment = SuggestPayment.find_by_suggest_delivery_id(@suggest_delivery.id)
    @confirmed_user = User.find( @accepted_suggest.user_id)
    if @suggest_creator == current_user && @suggest_payment.approved
      flash[:complete] = "You've chosen to mark <br><b>#{@suggest_delivery.size} Sized Items</b><br> delivery suggestion as <br><div class='complete'><b>complete!</b></div>
                                            <div class='sub_flash_text'>A payment of <b>#{@suggest_delivery.cost} #{@suggest_delivery.currency}</b> will be transferred to you. <br></div>".html_safe
        #NotifMailer.new_complete_suggest(@suggest_creator,@confirmed_user,@suggest_delivery).deliver
        redirect_to :controller => 'payments',
                                  :action => 'execute',
                                  :req_or_sugg => "suggest_delivery",
                                  :task_creator_id => @suggest_creator.id,
                                  :confirmed_user_id => @confirmed_user.id,
                                  :task_id => @suggest_delivery.id,
                                  :accepted_task_id => @accepted_suggest.id
    else
      flash[:cannot] = "Only the creator of the suggestion can mark it as complete."
    end
  end

  private

  def correct_user
    @suggest_delivery = current_user.suggest_deliveries.find_by_id(params[:id])
    redirect_to :back if @suggest_delivery.nil? && !current_user.try(:admin?)
  end

end