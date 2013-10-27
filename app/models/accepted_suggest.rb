class AcceptedSuggest < ActiveRecord::Base
  attr_accessible :confirmed, :complete
  belongs_to :suggest_delivery
  belongs_to :user

  validates :suggest_delivery_id, presence: true
  validates :user_id, presence: true
  validates_uniqueness_of :user_id, :scope => :suggest_delivery_id, :message => "You've already accepted this suggestion..."
  validate :unique_confirmation
  validate :complete_only_confirmed

  def unique_confirmation
    if !self.class.where('confirmed = ? AND suggest_delivery_id = ?', true, self.suggest_delivery_id).empty?
      errors.add :confirmed, "You cannot confirm more than one user per suggestion..."
    end
  end

  def complete_only_confirmed
    if (self.confirmed == false) && (self.complete == true)
      errors.add :complete, "You cannot complete unconfirmed requests..."
    end
  end

  def confirm_accepted_suggest
    self. update_attribute(:confirmed, true)
  end

  def cancel_accepted_suggest
    self. update_attribute(:confirmed, false)
  end

  def complete_accepted_suggest
    self. update_attribute(:complete, true)
  end

  def other_user_for_suggest
    User.find_by_id(self.user_id)
  end

end
