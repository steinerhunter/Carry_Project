class RequestPayment < ActiveRecord::Base
  attr_accessible :user_id, :request_delivery_id, :payKey, :status
  belongs_to :user

  validates :user_id, :presence => { :message => "Must be owned by some user..."}
  validates :request_delivery_id, :presence => { :message => "Must be associated with a certain request delivery..."}
  validates :payKey, :presence => { :message => "Must have a preapprovalKey..."}
  validates :status, :presence => { :message => "Must have a status..."}

end
