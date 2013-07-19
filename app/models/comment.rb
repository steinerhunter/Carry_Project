class Comment < ActiveRecord::Base
  attr_accessible :commentable_id, :commentable_type, :content
  belongs_to :commentable, :polymorphic => true

  def user
    return current_user
  end
end
