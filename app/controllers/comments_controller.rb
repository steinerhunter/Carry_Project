class CommentsController < ApplicationController
  respond_to :html, :js

  def index
    @commentable = find_commentable
    @comments = @commentable.comments
  end

  def create
    @commentable = find_commentable
    @comment = @commentable.comments.new(params[:comment])
    @comment.user_id = current_user.id
    if @comment.save
      respond_with @commentable, :location => @commentable
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