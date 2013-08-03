class AcceptedSuggest < ActiveRecord::Base
  belongs_to :suggest_delivery
  belongs_to :user

  validates :suggest_delivery_id, presence: true
  validates :user_id, presence: true
  validates_uniqueness_of :user_id, :scope => :suggest_delivery_id, :message => "You've already accepted this suggestion..."
  validate :correct_user

  def correct_user
    if self.user == self.suggest_delivery.user
      errors.add :user_id, "You cannot accept your own suggestions..."
    end
  end
end
