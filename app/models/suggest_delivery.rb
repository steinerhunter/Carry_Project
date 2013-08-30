class SuggestDelivery < ActiveRecord::Base
  attr_accessible :from, :to, :when, :more_details, :size, :cost, :currency
  has_many :comments, :as => :commentable
  has_many :accepted_suggests # just the 'relationships'
  has_many :accepted_by, through: :accepted_suggests, source: :user
  belongs_to :user

  validates :size, :presence => { :message => "It seems you left out delivery size..."}
  validates :from, :presence => { :message => "We need to know where you're coming from..."}
  validates :to, :presence => { :message => "We need to know where you're going to..."}
  validates :cost, :presence => { :message => "We need to know how much you will charge..."}
  validates :cost, :numericality => { :only_integer => true, :message => "Only whole numbers please..." }
  validates :currency, :presence => { :message => "It seems you left out currency..."}
  validate :date_not_in_past

  default_scope order: 'suggest_deliveries.created_at DESC'

  def date_not_in_past
    if !self.when.nil?
      if self.when < Date.today
        errors.add(:when, 'You selected a date from the past...')
      end
    end
  end

  def accept_suggest
    self.update_attribute(:status, "Pending Confirmation")
  end

  def cancel_suggest
    self.update_attribute(:status, "Open")
  end

  def confirm_suggest
    self.update_attribute(:status, "Confirmed")
  end

  def complete_suggest
    self.update_attribute(:status, "Complete")
  end

  def accepted_suggest_confirmed
    AcceptedSuggest.find_by_suggest_delivery_id_and_confirmed(self.id, true)
  end

  def accepted_suggest_not_confirmed
    AcceptedSuggest.where("suggest_delivery_id = ? AND confirmed = ?",self.id,false).pluck(:user_id)
  end


end
