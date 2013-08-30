class CommentsController < ApplicationController
  respond_to :html, :js

  def index
    @commentable = find_commentable
    @comments = @commentable.comments
  end

  def create
    @commentable = find_commentable
    @comment = @commentable.comments.new(params[:comment])
    if current_user.nil?
      @comment.user_id = 0
      if @comment.valid?
        session[:comment_content] = @comment.content
      end
    else
      session[:comment_content] = nil
      @comment.user_id = current_user.id
      if @comment.save
        respond_with @commentable, :location => @commentable
      end
    end

  end

  def destroy
    @commentable = find_commentable
    @comment = Comment.find(params[:id])
    @comment.destroy
    respond_with @commentable, :location => @commentable
  end

  private

  def find_commentable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
    nil
  end

end