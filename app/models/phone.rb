class Phone < ActiveRecord::Base
  VERIFICATION_CODE_LENGTH = 6

  attr_accessible :phone, :user_id, :verified

  validates :user_id, :presence => true
  validates :phone,   :presence => {:message => "It seems you forgot to add your number..."}

  IL_VALID_PHONE_REGEX = /\A^05\d{8}$\z/i
  US_VALID_PHONE_REGEX = /\A^[0-9]{10}$\z/i

  validates :phone, :format => { with: IL_VALID_PHONE_REGEX, :message =>"Phone number should be like '0521234567'"}, :on => :create, :if => request.location.country == "Israel"
  validates :phone, :format => { with: US_VALID_PHONE_REGEX, :message =>"Phone number should be like '1234567890'"}, :on => :create, :if => request.location.country == "United States"

  def generate_verification_code
    self.verification_code = VERIFICATION_CODE_LENGTH.times.map{ Random.rand(9) + 1 }.join
    self.save!
  end

  def confirm_phone
    self.update_attribute(:verified,true)
    self.save!
  end

  def normalize_number
    self.normalized_phone = self.phone.tr('^A-Za-z0-9', '')
    self.normalized_phone = self.normalized_phone[1..-1]
    self.normalized_phone = "+972" + self.normalized_phone
    self.save!
  end

end
