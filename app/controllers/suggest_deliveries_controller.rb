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
        flash[:success] = "Thank you!<br>
                                              <div class='sub_flash_text'>Your delivery suggestion was successfully added to our lists. <br>
                                              There are some more details to add though.<br>
                                              <b style=\"color:#ff9054\">Add</b> <img src=\"../assets/missing_detail.png\"> all details and get priority in our lists!</div>".html_safe
        respond_with(@suggest_delivery) do |format|
          format.html { redirect_to suggest_delivery_url(@suggest_delivery)}
        end
      end
    end
  end

  def index
    @search = SuggestDelivery.search(params[:search])
    @suggest_feed_items = @search.all.sort_by { |a| a.has_all_details ? 0 : 1}
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
      render "edit_from.html.erb", :layout => "empty"
    end
  end

  def edit_to
    @suggest_delivery = SuggestDelivery.find(params[:suggest_delivery_id])
    if @suggest_delivery.user == current_user
      render "edit_to.html.erb", :layout => "empty"
    end
  end

  def edit_due_date
    @suggest_delivery = SuggestDelivery.find(params[:suggest_delivery_id])
    if @suggest_delivery.user == current_user
      render "edit_due_date.html.erb", :layout => "empty"
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
    if @suggest_delivery.status != "Open"
      flash[:failure] = "Sorry!<br><div class='sub_flash_text'>You cannot edit the details of your suggestion since someone has already accepted it.</div>".html_safe
      redirect_to :back
    else
      if @suggest_delivery.update_attributes( params[:suggest_delivery])
        @suggest_delivery.check_all_details
        flash[:success] = "Thank you!<br><div class='sub_flash_text'>Your details were successfully updated.</div>".html_safe
        respond_with(@suggest_delivery) do |format|
          format.html { redirect_to suggest_delivery_url(@suggest_delivery)}
        end
      end
    end
  end

  def destroy
    @suggest_delivery = SuggestDelivery.find(params[:id])
    if @suggest_delivery.status != "Open"
      flash[:failure] = "Sorry!<br><div class='sub_flash_text'>You cannot delete your delivery suggestion since someone has already accepted it.</div>".html_safe
      redirect_to :back
    else
      @suggest_delivery.destroy
      flash[:success] = "Thank you!<br><div class='sub_flash_text'>Your delivery suggestion has been successfully deleted.</div>".html_safe
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
        flash[:success] = "Thank you!<br>
                                              <div class='sub_flash_text'>You've chosen to accept <b>#{@suggest_delivery.size} sized items</b> delivery suggestion.<br>
                                              <b>#{@suggest_delivery.user.name}</b>, the creator of the suggestion, will be notified. <br>
                                              Now <b>#{@suggest_delivery.user.name}</b> must confirm you.</div>".html_safe
        @accepted_suggest = AcceptedSuggest.find_by_suggest_delivery_id(@suggest_delivery.id)
        @creating_user = User.find_by_id(@suggest_delivery.user_id)
        @accepting_user = User.find_by_id(@accepted_suggest.user_id)
        NotifMailer.new_accepted_suggest(@creating_user,@accepting_user,@suggest_delivery).deliver
      elsif type == "cancel"
        if @suggest_delivery.status == "Open"
          flash[:failure] = "Sorry!<br><div class='sub_flash_text'>You cannot cancel an Open request.</div>".html_safe
          redirect_to :back
        elsif @suggest_delivery.status == "Confirmed"
          flash[:failure] = "Sorry!<br><div class='sub_flash_text'>You cannot cancel a Confirmed suggestion.</div>".html_safe
          redirect_to :back
        elsif @suggest_delivery.status == "Complete"
          flash[:failure] = "Sorry!<br><div class='sub_flash_text'>You cannot cancel a Complete suggestion.</div>".html_safe
          redirect_to :back
        else
          current_user.suggest_accepts.delete(@suggest_delivery)
          redirect_to :back
          @suggest_delivery.cancel_suggest
          flash[:success] = "Thank you!<br><div class='sub_flash_text'>You've chosen to cancel your acceptance of the suggestion.</div>".html_safe
        end
      else
        redirect_to :back
      end
    else
      redirect_to :back
      flash[:failure] = "Sorry!<br><div class='sub_flash_text'>You cannot accept your own delivery suggestions.</div>".html_safe
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
        flash[:success] = "Great!<br><div class='sub_flash_text'>You've chosen to confirm <b>#{@confirmed_user.name}</b>
                                            For your suggestion<b> #{@suggest_delivery.size} sized items</b></div>".html_safe
        if Rails.env.production?
          NotifMailer.new_confirmed_suggest(@suggest_creator,@confirmed_user,@suggest_delivery).deliver
        end
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
      if Rails.env.production?
        NotifMailer.new_confirmed_suggest(@suggest_creator,@confirmed_user,@suggest_delivery).deliver
      end
      redirect_to :controller => 'payments',
                  :action => 'checkout',
                  :req_or_sugg => "suggest_delivery",
                  :task_creator_id => @suggest_creator.id,
                  :confirmed_user_id => @confirmed_user.id,
                  :task_id => @suggest_delivery.id,
                  :accepted_task_id => @accepted_suggest.id
    else
      flash[:failure] = "Sorry!<br><div class='sub_flash_text'>Only the creator of the suggestion can confirm it.</div>".html_safe
    end
  end

  def complete
    @accepted_suggest = AcceptedSuggest.find(params[:accepted_suggest_id])
    @suggest_delivery = SuggestDelivery.find(params[:suggest_delivery_id])
    @suggest_creator = User.find(@suggest_delivery.user_id)
    @suggest_payment = SuggestPayment.find_by_suggest_delivery_id(@suggest_delivery.id)
    @confirmed_user = User.find( @accepted_suggest.user_id)
    if @suggest_creator == current_user && @suggest_payment.approved
      flash[:success] = "Great!<br><div class='sub_flash_text'>You've chosen to mark <b>#{@suggest_delivery.size} Sized Items</b> delivery suggestion as complete.</div>".html_safe
      if Rails.env.production?
        NotifMailer.new_complete_suggest(@suggest_creator,@confirmed_user,@suggest_delivery).deliver
      end
        redirect_to :controller => 'payments',
                                  :action => 'execute',
                                  :req_or_sugg => "suggest_delivery",
                                  :task_creator_id => @suggest_creator.id,
                                  :confirmed_user_id => @confirmed_user.id,
                                  :task_id => @suggest_delivery.id,
                                  :accepted_task_id => @accepted_suggest.id
    else
      redirect_to activity_url
    end
  end

  private

  def correct_user
    @suggest_delivery = current_user.suggest_deliveries.find_by_id(params[:id])
    redirect_to :back if @suggest_delivery.nil? && !current_user.try(:admin?)
  end

end