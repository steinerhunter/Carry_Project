class SuggestDelivery < ActiveRecord::Base
  attr_accessible :from, :to, :when, :more_details, :size, :cost
  belongs_to :user

  validates :user_id, presence: true
  validates :from, :presence => { :message => "We need to know where you're coming from..."}
  validates :to, :presence => { :message => "We need to know where you're going to..."}
  validates :when, :presence => { :message => "We need to know when you're planning to go..."}
  validates :more_details, :presence => { :message => "How about you elaborate a little?"}
  validates :cost, :presence => { :message => "We need to know how much you will charge..."}
  validates :cost, :numericality => { :only_integer => true, :message => "Only whole numbers please..." }

  default_scope order: 'suggest_deliveries.created_at DESC'
end
