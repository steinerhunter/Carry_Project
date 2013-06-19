class RequestDelivery < ActiveRecord::Base
  attr_accessible :from, :to, :what, :when, :more_details, :cost, :size
  belongs_to :user

  validates :user_id, presence: true
  validates :from, :presence => { :message => "We're going to need your delivery's origin..."}
  validates :to, :presence => { :message => "It seems you didn't tell us about your delivery's destination..."}
  validates :what, :presence => { :message => "You do want to deliver something, right...?"}
  validates :when, :presence => { :message => "Surely you need your delivery to ship sometime...?"}
  validates :more_details, :presence => { :message => "How about you elaborate a little?"}
  validates :cost, :presence => { :message => "We need to know how much you will pay..."}
  validates :cost, :numericality => { :only_integer => true, :message => "Only whole numbers please..." }

  default_scope order: 'request_deliveries.created_at DESC'
end
