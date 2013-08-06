class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy]
  before_filter :correct_user, only: [:edit, :update]
  before_filter :admin_user, only: :destroy
  respond_to :html, :js

  def show
    @user = User.find(params[:id])
  end

  def new
    if signed_in?
      redirect_to root_path
    end
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Carry Project!"
      respond_with(@user, :location => root_path)
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User successfully deleted."
    redirect_to users_url
  end

  def edit
  end

  def update
       if @user.update_attributes( params[:user])
      flash[:success] = "Profile successfully updated!"
      sign_in @user
      respond_with(@user, :location => user_path(@user))
    end
  end

  def index
    @users = User.all
  end

  def empty_trash
    current_user.mailbox.trash.each do |conversation|
      conversation.receipts_for(current_user).update_all(:deleted => true)
    end
    redirect_to conversations_path
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to root_path unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end


end
