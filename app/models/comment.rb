class Comment < ActiveRecord::Base
  attr_accessible :commentable_id, :commentable_type, :content
  belongs_to :commentable, :polymorphic => true
  belongs_to :user

  validates :user_id, presence: true
  validates :content, :presence => { :message => "Got nothing to ask?"}

end
