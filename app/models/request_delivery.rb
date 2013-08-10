class RequestDelivery < ActiveRecord::Base
  attr_accessible :from, :to, :what, :when, :more_details, :cost, :currency, :size, :sending_person, :receiving_person
  has_many :comments, :as => :commentable
  has_many :accepted_requests # just the 'relationships'
  has_many :accepted_by, through: :accepted_requests, source: :user
  belongs_to :user

  validates :user_id, presence: true
  validates :what, :presence => { :message => "You do want to send something, right...?"}
  validates :what, :length => { maximum: 20, :message => "Surely it can be described in less than 20 chars."}
  validates :from, :presence => { :message => "We're going to need your delivery's origin..."}
  validates :to, :presence => { :message => "It seems you didn't share your delivery's destination..."}
  validates :cost, :presence => { :message => "We need to know how much you will pay..."}
  validates :cost, :numericality => { :only_integer => true, :message => "Only whole numbers please..." }
  validates :currency, :presence => { :message => "It seems you left out currency..."}

  default_scope order: 'request_deliveries.created_at DESC'

  def accept_request
    self.update_attribute(:status, "Pending Confirmation")
  end

  def cancel_request
    self.update_attribute(:status, "Open")
  end

end
