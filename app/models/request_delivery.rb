class RequestDelivery < ActiveRecord::Base
  attr_accessible :from, :to, :when, :more_details
  belongs_to :user

  validates :user_id, presence: true
  validates :from, :presence => { :message => "We're going to need your delivery's origin..."}
  validates :to, :presence => { :message => "It seems you didn't tell us about your delivery's destination..."}
  validates :when, :presence => { :message => "Surely you need your delivery to ship sometime...?"}
  validates :more_details, :presence => { :message => "How about you elaborate a little?"}

  default_scope order: 'request_deliveries.created_at DESC'
end
