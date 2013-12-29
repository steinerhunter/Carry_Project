class RequestDelivery < ActiveRecord::Base
  attr_accessible :from, :to, :what, :when, :more_details, :cost, :currency, :size, :sending_person, :receiving_person, :sending_phone, :receiving_phone, :delivery_type
  has_many :comments, :as => :commentable
  has_many :accepted_requests
  has_many :accepted_by, through: :accepted_requests, source: :user
  has_many :taken_giveaways
  has_many :taken_by, through: :taken_giveaways, source: :user
  belongs_to :user

  validates :what, :presence => { :message => "You forgot to mention what you were giving..."}
  validates :what, :length => { maximum: 20, :message => "Surely it can be described in less than 20 chars."}
  validates :from, :presence => { :message => "Where can your item be picked up from?"}
  validates :size, :presence => { :message => "It seems you left out size..."}
  #validates :to, :presence => { :message => "It seems you didn't share your delivery's destination..."}
  #validates :cost, :presence => { :message => "We need to know how much you will pay..."}
  #validates :cost, :numericality => { :only_integer => true, :message => "Only whole numbers please..." }
  #validates :currency, :presence => { :message => "It seems you left out currency..."}
  #validate :date_not_in_past

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
    if self.what.present? &&
          self.from.present? &&
          self.to.present? &&
          self.delivery_type.present? &&
          self.sending_person.present? &&
          self.receiving_person.present? &&
          self.sending_phone.present? &&
          self.receiving_phone.present?
      self.update_attribute(:has_all_details,true)
    else
      self.update_attribute(:has_all_details,false)
    end
  end

  def set_giver
    giver = User.find_by_id(self.user.id)
    self.update_attribute(:sending_person, giver.name)
  end

  def set_giver_phone
    giver_phone = Phone.find_by_user_id(self.user.id)
    self.update_attribute(:sending_phone, giver_phone.phone)
  end

  def take_request
    take_giveaway = TakenGiveaway.find_by_request_delivery_id(self.id)
    taking_user = User.find_by_id(take_giveaway.user_id)
    taking_phone = Phone.find_by_user_id(taking_user.id)
    self.update_attribute(:receiving_phone, taking_phone.phone)
    self.update_attribute(:receiving_person, taking_user.name)
    self.update_attribute(:status, "Taken")
    take_giveaway.update_attribute(:taken, true)
  end

  def calculate_distance
    from = self.encode_location(self.from)
    to = self.encode_location(self.to)
    @url = "https://maps.googleapis.com/maps/api/distancematrix/json?origins="+from+"&destinations="+to+"&mode=driving&language=en-US&sensor=false"
    @response = HTTParty.get(@url)
    @distance_text = @response['rows'][0]['elements'][0]['distance']['text']
    @distance_value = @response['rows'][0]['elements'][0]['distance']['value']
    self.update_attribute(:distance_text,@distance_text)
    self.update_attribute(:distance_value,@distance_value)
  end

  def encode_location(location)
    location.gsub(",","").gsub(/\s/,'+')
  end

  def set_cost
    @cost = self.distance_value / 1000 + 20
    self.update_attribute(:cost,@cost)
  end

  def get_the_item
    self.update_attribute(:status,"ReceiverConfirmed")
  end

  def wait_for_transporter
    self.update_attribute(:status,"WaitingForTransporter")
  end

  def got_the_item
    self.complete_request
  end

  def unpublish
    self.update_attribute(:status,"Unpublished")
  end

  def publish
    self.update_attribute(:status,"Open")
    self.set_giver_phone
  end

  def accept_request
    self.update_attribute(:status, "Pending Confirmation")
  end

  def unaccept_request
    @accepted_requests = AcceptedRequest.find_all_by_request_delivery_id(self.id)
    if @accepted_requests.count == 0
      self.update_attribute(:status, "WaitingForTransporter")
    end
  end

  def untake_request
    self.update_attribute(:to, nil)
    self.update_attribute(:delivery_type, nil)
    self.update_attribute(:receiving_person, nil)
    self.update_attribute(:receiving_phone, nil)
    self.update_attribute(:has_all_details, false)
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

  def review_transporter
    self.update_attribute(:transporter_reviewed, true)
    self.update_attribute(:status, "TransporterReviewed")
  end

  def confirmed_taker
    @giveaway = TakenGiveaway.find_by_request_delivery_id_and_taken(self.id,true)
    User.find_by_id(@giveaway.user_id)
  end

  def possible_transporters
    @accepted_requests = AcceptedRequest.where("request_delivery_id = ?",self.id)
    @accepted_requests_user_id = @accepted_requests.pluck(:user_id)
    User.find_all_by_id(@accepted_requests_user_id)
  end

  def accepted_request_confirmed
    AcceptedRequest.find_by_request_delivery_id_and_confirmed(self.id, true)
  end

  def accepted_request_not_confirmed
    AcceptedRequest.where("request_delivery_id = ? AND confirmed = ?",self.id,false).pluck(:user_id)
  end

end
