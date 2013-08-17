class AcceptedSuggest < ActiveRecord::Base
  attr_accessible :confirmed
  belongs_to :suggest_delivery
  belongs_to :user

  validates :suggest_delivery_id, presence: true
  validates :user_id, presence: true
  validates_uniqueness_of :user_id, :scope => :suggest_delivery_id, :message => "You've already accepted this suggestion..."
  validate :unique_confirmation
  validate :correct_user

  def correct_user
    if self.user == self.suggest_delivery.user
      errors.add :user_id, "You cannot accept your own suggestions..."
    end
  end

  def unique_confirmation
    if !self.class.where('confirmed = ? AND suggest_delivery_id = ?', true, self.suggest_delivery_id).empty?
      errors.add :confirmed, "You cannot confirm more than one user per suggestion..."
    end
  end

  def confirm_accepted_suggest
    self. update_attribute(:confirmed, true)
  end

  def user_for_confirmed_suggest
    User.find_by_id(self.user_id)
  end

end
