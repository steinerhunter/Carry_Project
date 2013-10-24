class SuggestPayment < ActiveRecord::Base
  attr_accessible :user_id, :suggest_delivery_id, :preapprovalKey, :status
  belongs_to :user

  validates :user_id, :presence => { :message => "Must be owned by some user..."}
  validates :suggest_delivery_id, :presence => { :message => "Must be associated with a certain suggested delivery..."}
  validates :preapprovalKey, :presence => { :message => "Must have a preapprovalKey..."}
  validates :status, :presence => { :message => "Must have a status..."}
end
