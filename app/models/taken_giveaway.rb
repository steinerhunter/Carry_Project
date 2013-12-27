class TakenGiveaway < ActiveRecord::Base

  belongs_to :request_delivery
  belongs_to :user

  validates :request_delivery_id, presence: true
  validates :user_id, presence: true
  validates_uniqueness_of :user_id, :scope => :request_delivery_id, :message => "You've already chosen to take this giveaway..."
  validate :unique_taker

  def unique_taker
    if !self.class.where('taken = ? AND request_delivery_id = ?', true, self.request_delivery_id).empty?
      errors.add :confirmed, "This giveaway has already been taken..."
    end
  end

end
