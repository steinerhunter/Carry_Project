class RequestPayment < ActiveRecord::Base
  attr_accessible :user_id, :request_delivery_id, :payKey, :status
  belongs_to :user

  validates :user_id, :presence => { :message => "Must be owned by some user..."}
  validates :request_delivery_id, :presence => { :message => "Must be associated with a certain request delivery..."}
  validates :payKey, :presence => { :message => "Must have a payKey..."}
  validates :status, :presence => { :message => "Must have a status..."}

  def check_status(status)
    self. status == status
  end

end
