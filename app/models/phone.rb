class Phone < ActiveRecord::Base
  VERIFICATION_CODE_LENGTH = 6

  attr_accessible :phone, :user_id, :verified

  validates :user_id, :presence => true
  validates :phone,   :presence => {:message => "It seems you forgot to add your number..."}
  validates :phone,   :numericality => {:message => "Only numbers here please..."}

  def generate_verification_code
    self.verification_code = VERIFICATION_CODE_LENGTH.times.map{ Random.rand(9) + 1 }.join
    self.save!
  end

  def confirm_phone
    self.update_attribute(:verified,true)
    self.save!
  end

  def normalize_number
    self.phone = self.phone[1..-1]
    self.phone = "+972" + self.phone
    self.save!
  end

end
