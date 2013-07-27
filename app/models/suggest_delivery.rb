class SuggestDelivery < ActiveRecord::Base
  attr_accessible :from, :to, :when, :more_details, :size, :cost, :currency
  has_many :comments, :as => :commentable
  belongs_to :user

  validates :user_id, presence: true
  validates :from, :presence => { :message => "We need to know where you're coming from..."}
  validates :to, :presence => { :message => "We need to know where you're going to..."}
  validates :size, :presence => { :message => "It seems you left out delivery size..."}
  validates :more_details, :presence => { :message => "How about you elaborate a little?"}
  validates :cost, :presence => { :message => "We need to know how much you will charge..."}
  validates :cost, :numericality => { :only_integer => true, :message => "Only whole numbers please..." }
  validates :currency, :presence => { :message => "It seems you left out currency..."}

  default_scope order: 'suggest_deliveries.created_at DESC'
end
