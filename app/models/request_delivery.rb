class RequestDelivery < ActiveRecord::Base
  attr_accessible :from, :to, :when, :more_details
  belongs_to :user

  validates :user_id, presence: true
  validates :from, :presence => { :message => "OOPS! Looks like you didn't tell us what you wanted..."}
  validates :to, :presence => { :message => "OOPS! Surely you'd like to give something back, right...?"}
  validates :when, :presence => { :message => "OOPS! We need to know which country sells that..."}
  validates :more_details, :presence => { :message => "OOPS! Looks like you didn't tell us a bit more about what you wanted..."}

  default_scope order: 'request_deliveries.created_at DESC'
end
