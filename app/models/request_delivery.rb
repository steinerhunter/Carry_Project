class RequestDelivery < ActiveRecord::Base
  attr_accessible :from, :to, :what, :when, :more_details, :cost, :currency, :size, :sending_person, :receiving_person, :sending_phone, :receiving_phone, :delivery_type, :attachment
  has_many :comments, :as => :commentable
  has_many :accepted_requests
  has_many :accepted_by, through: :accepted_requests, source: :user
  has_many :taken_giveaways
  has_many :taken_by, through: :taken_giveaways, source: :user
  belongs_to :user

  mount_uploader :attachment, AttachmentUploader

  validates :what, :presence => { :message => "You forgot to mention what you were giving..."}
  validates :what, :length => { maximum: 20, :message => "Surely it can be described in less than 20 chars."}
  validates :from, :presence => { :message => "Where can your item be picked up from?"}
  validates :size, :presence => { :message => "It seems you left out size..."}
  #validates :to, :presence => { :message => "It seems you didn't share your delivery's destination..."}
  #validates :cost, :presence => { :message => "We need to know how much you will pay..."}
  #validates :cost, :numericality => { :only_integer => true, :message => "Only whole numbers please..." }
  #validates :currency, :presence => { :message => "It seems you left out currency..."}
  #validate :date_not_in_past

  VALID_PHONE_REGEX = /\A^05\d{8}$\z/i
  validates :sending_phone, :format => { with: VALID_PHONE_REGEX, :message =>"Phone number should be like '0521234567'"}, allow_blank: true
  validates :receiving_phone, :format => { with: VALID_PHONE_REGEX, :message =>"Phone number should be like '0521234567'"}, allow_blank: true

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
    self.update_attribute(:currency,"ILS")
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
    #self.set_giver_phone
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

  def facebook_feed_dialog_url
    "https://www.facebook.com/dialog/feed?"
  end

  def facebook_page_link
    "link="+Rails.application.routes.url_helpers.request_delivery_path(self).to_s+"&"
  end

  def facebook_app_id
    "app_id="+ENV['FACEBOOK_APP_ID'].to_s+"&"
  end

  def facebook_name_giveaway
    "name=sendd.me Giveaway&"
  end

  def facebook_name_pick_up
    "name=sendd.me Pick Up&"
  end

    def facebook_picture
      if self.attachment.present?
      "picture="+self.attachment_url(:facebook_share).to_s+"&"
      else
        ""
      end
    end

  def facebook_caption
    "caption="+self.what.to_s+"&"
  end

  def facebook_description_giveaway_owner
    "description=I'm giving away "+self.what.to_s+". Pick up is from "+self.from.to_s+". Interested?&"
  end

  def facebook_description_giveaway_other
    "description=Someone is giving away "+self.what.to_s+". Pick up is from "+self.from.to_s+". Interested?&"
  end

  def facebook_description_pick_up_owner
    if self.cost.present?
      "description=I need to pick up "+self.what.to_s+" from "+self.from+", and I'm willing to pay "+self.cost.to_s+" "+self.currency.to_s+" for it. Interested?&"
    end
  end

  def facebook_description_pick_up_other
    if self.cost.present?
      "description=Someone needs to pick up "+self.what.to_s+" from "+self.from+", and they're willing to pay "+self.cost.to_s+" "+self.currency.to_s+" for it. Interested?&"
    end
  end

  def facebook_redirect_uri
    "redirect_uri="+Rails.application.routes.url_helpers.request_delivery_path(self).to_s+"&"
  end

  def facebook_display
    "popup"
  end

  def facebook_share_giveaway_owner
    replace_spaces(self.facebook_feed_dialog_url+self.facebook_page_link+self.facebook_app_id+
                       self.facebook_name_giveaway+self.facebook_picture+self.facebook_caption+self.facebook_description_giveaway_owner+
                       self.facebook_redirect_uri+self.facebook_display)
  end

  def facebook_share_giveaway_other
    replace_spaces(self.facebook_feed_dialog_url+self.facebook_page_link+self.facebook_app_id+
                       self.facebook_name_giveaway+self.facebook_picture+self.facebook_caption+self.facebook_description_giveaway_other+
                       self.facebook_redirect_uri+self.facebook_display)
  end

  def facebook_share_pick_up_owner
    if self.cost.present?
      replace_spaces(self.facebook_feed_dialog_url+self.facebook_page_link+self.facebook_app_id+
                         self.facebook_name_pick_up+self.facebook_picture+self.facebook_caption+self.facebook_description_pick_up_owner+
                         self.facebook_redirect_uri+self.facebook_display)
    end
  end

  def facebook_share_pick_up_other
    if self.cost.present?
      replace_spaces(self.facebook_feed_dialog_url+self.facebook_page_link+self.facebook_app_id+
                         self.facebook_name_pick_up+self.facebook_picture+self.facebook_caption+self.facebook_description_pick_up_other+
                         self.facebook_redirect_uri+self.facebook_display)
    end
  end

  def replace_spaces(str)
    str.gsub(",","").gsub(/\s/,'+')
  end
end
