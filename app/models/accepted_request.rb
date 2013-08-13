class AcceptedRequest < ActiveRecord::Base
  belongs_to :request_delivery
  belongs_to :user

  validates :request_delivery_id, presence: true
  validates :user_id, presence: true
  validates_uniqueness_of :user_id, :scope => :request_delivery_id, :message => "You've already accepted this request..."
  validate :unique_confirmation
  validate :correct_user


  def correct_user
    if self.user == self.request_delivery.user
      errors.add :user_id, "You cannot accept your own requests..."
    end
  end

  def unique_confirmation
    if !self.class.where('confirmed = ?', true).empty?
      errors.add :confirmed, "You cannot confirm more than one user per request..."
    end
  end

  def confirm_accepted_request
    self. update_attribute(:confirmed, true)
  end

end
