class AcceptedRequest < ActiveRecord::Base
  attr_accessible :confirmed, :complete
  belongs_to :request_delivery
  belongs_to :user

  validates :request_delivery_id, presence: true
  validates :user_id, presence: true
  validates_uniqueness_of :user_id, :scope => :request_delivery_id, :message => "You've already accepted this request..."
  validate :unique_confirmation
  validate :complete_only_confirmed

  def unique_confirmation
    if !self.class.where('confirmed = ? AND request_delivery_id = ?', true, self.request_delivery_id).empty?
      errors.add :confirmed, "You cannot confirm more than one user per request..."
    end
  end

  def complete_only_confirmed
    if (self.confirmed == false) && (self.complete == true)
      errors.add :complete, "You cannot complete unconfirmed requests..."
    end
  end

  def confirm_accepted_request
    self. update_attribute(:confirmed, true)
  end

  def complete_accepted_request
    self. update_attribute(:complete, true)
  end

  def user_for_confirmed_request
    User.find_by_id(self.user_id)
  end

end
