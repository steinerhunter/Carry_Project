class RequestDelivery < ActiveRecord::Base
  attr_accessible :from, :to, :when, :more_details
  belongs_to :user

  validates :user_id, presence: true

  default_scope order: 'request_deliveries.created_at DESC'
end
