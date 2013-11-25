class RequestDelivery < ActiveRecord::Base
  attr_accessible :from, :to, :what, :when, :more_details, :cost, :currency, :size, :sending_person, :receiving_person, :sending_phone, :receiving_phone
  has_many :comments, :as => :commentable
  has_many :accepted_requests # just the 'relationships'
  has_many :accepted_by, through: :accepted_requests, source: :user
  belongs_to :user

  validates :what, :presence => { :message => "You do want to send something, right...?"}
  validates :what, :length => { maximum: 20, :message => "Surely it can be described in less than 20 chars."}
  validates :from, :presence => { :message => "We're going to need your delivery's origin..."}
  validates :to, :presence => { :message => "It seems you didn't share your delivery's destination..."}
  validates :cost, :presence => { :message => "We need to know how much you will pay..."}
  validates :cost, :numericality => { :only_integer => true, :message => "Only whole numbers please..." }
  validates :currency, :presence => { :message => "It seems you left out currency..."}
  validate :date_not_in_past

  VALID_PHONE_REGEX = /\A^05\d([-]{1})\d{7}$\z/i
  validates :sending_phone, :format => { with: VALID_PHONE_REGEX, :message =>"Phone number should be like '052-1234567'"}, allow_blank: true
  validates :receiving_phone, :format => { with: VALID_PHONE_REGEX, :message =>"Phone number should be like '052-1234567'"}, allow_blank: true

  default_scope order: 'request_deliveries.created_at DESC'

  def date_not_in_past
    if !self.when.nil?
      if self.when < Date.today
        errors.add(:when, 'You selected a date from the past...')
      end
    end
  end

  def check_all_details
    if self.when.present? &&
          self.size.present? &&
          self.sending_person.present? &&
          self.receiving_person.present? &&
          self.sending_phone.present? &&
          self.receiving_phone.present?
      self.update_attribute(:has_all_details,true)
    else
      self.update_attribute(:has_all_details,false)
    end
  end

  def accept_request
    self.update_attribute(:status, "Pending Confirmation")
  end

  def cancel_request
    self.update_attribute(:status, "Open")
  end

  def confirm_request
    self.update_attribute(:status, "Confirmed")
  end

  def unconfirm_request
    self.accept_request
  end

  def complete_request
    self.update_attribute(:status, "Complete")
  end

  def accepted_request_confirmed
    AcceptedRequest.find_by_request_delivery_id_and_confirmed(self.id, true)
  end

  def accepted_request_not_confirmed
    AcceptedRequest.where("request_delivery_id = ? AND confirmed = ?",self.id,false).pluck(:user_id)
  end

end
