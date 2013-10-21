class UserReview < ActiveRecord::Base
  attr_accessible :from_user_id, :review_content, :to_user_id, :req_or_sugg, :task_id, :pos_or_neg, :job_type
  belongs_to :user

  validates :from_user_id, :presence => true
  validates :to_user_id, :presence => true
  validates :req_or_sugg, :presence => true
  validates :task_id, :presence => true
  validates :job_type, :presence => true
  validates :pos_or_neg, :presence => { :message => "Your experience was either Good or Bad, right?"}
  validates :review_content, :presence => { :message => "Please add a sentence about your experience..."}

end
