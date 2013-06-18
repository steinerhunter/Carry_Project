class SuggestDelivery < ActiveRecord::Base
  attr_accessible :from, :to, :when, :more_details
  belongs_to :user

  validates :user_id, presence: true
  validates :from, :presence => { :message => "We need to know where you're coming from..."}
  validates :to, :presence => { :message => "We need to know where you're going to..."}
  validates :when, :presence => { :message => "We need to know when you're planning to go..."}
  validates :more_details, :presence => { :message => "How about you elaborate a little?"}

  default_scope order: 'suggest_deliveries.created_at DESC'
end
