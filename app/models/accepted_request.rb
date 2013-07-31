class AcceptedRequest < ActiveRecord::Base
  belongs_to :request_delivery
  belongs_to :user

  validates :request_delivery_id, presence: true
  validates :user_id, presence: true
  validates_uniqueness_of :user_id, :scope => :request_delivery_id, :message => "You've already accepted this request..."
  validate :correct_user

  def correct_user
    if self.user == self.request_delivery.user
      errors.add :user_id, "You cannot accept your own requests..."
    end
  end

end
