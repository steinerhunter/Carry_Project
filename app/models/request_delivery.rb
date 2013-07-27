class RequestDelivery < ActiveRecord::Base
  attr_accessible :from, :to, :what, :when, :more_details, :cost, :currency, :size, :sending_person, :receiving_person
  has_many :comments, :as => :commentable
  belongs_to :user

  validates :user_id, presence: true
  validates :from, :presence => { :message => "We're going to need your delivery's origin..."}
  validates :to, :presence => { :message => "It seems you didn't share your delivery's destination..."}
  validates :what, :presence => { :message => "You do want to deliver something, right...?"}
  validates :what, :length => { maximum: 20, :message => "Surely it can be described in less than 20 chars."}
  validates :size, :presence => { :message => "It seems you left out delivery size..."}
  validates :more_details, :presence => { :message => "How about you elaborate a little?"}
  validates :more_details, :length => { maximum: 200, :message => "Surely it can be described in less than 200 chars."}
  validates :cost, :presence => { :message => "We need to know how much you will pay..."}
  validates :cost, :numericality => { :only_integer => true, :message => "Only whole numbers please..." }
  validates :currency, :presence => { :message => "It seems you left out currency..."}
  validates :sending_person, :presence => { :message => "Who is in charge of giving the package away?"}
  validates :receiving_person, :presence => { :message => "Who is in charge of accepting the package?"}

  default_scope order: 'request_deliveries.created_at DESC'
end
