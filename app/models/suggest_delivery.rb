class SuggestDelivery < ActiveRecord::Base
  attr_accessible :from, :to, :when, :more_details, :size, :cost, :currency
  has_many :comments, :as => :commentable
  has_many :accepted_suggests # just the 'relationships'
  has_many :accepted_by, through: :accepted_suggests, source: :user
  belongs_to :user

  validates :user_id, presence: true
  validates :size, :presence => { :message => "It seems you left out delivery size..."}
  validates :from, :presence => { :message => "We need to know where you're coming from..."}
  validates :to, :presence => { :message => "We need to know where you're going to..."}
  validates :cost, :presence => { :message => "We need to know how much you will charge..."}
  validates :cost, :numericality => { :only_integer => true, :message => "Only whole numbers please..." }
  validates :currency, :presence => { :message => "It seems you left out currency..."}

  default_scope order: 'suggest_deliveries.created_at DESC'

  def accept_suggest
    self.update_attribute(:status, "Pending Confirmation")
  end

  def cancel_suggest
    self.update_attribute(:status, "Open")
  end
  
end
