# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation, :only_facebook
  has_secure_password
  acts_as_messageable
  has_many :request_deliveries, dependent: :destroy
  has_many :taken_giveaways
  has_many :request_takes, through: :taken_giveaways, source: :request_delivery
  has_many :accepted_requests
  has_many :request_accepts, through: :accepted_requests, source: :request_delivery
  has_many :authentications

  has_many :suggest_deliveries, dependent: :destroy
  has_many :accepted_suggests
  has_many :suggest_accepts, through: :accepted_suggests, source: :suggest_delivery


  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token

  validates :name, :presence => { :message => "Looks like you didn't tell us your name..."}
  validates :name, :length => { maximum: 30 , :message => "Your name seems a bit too long..."}

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, :presence => { :message => "We're going to need your Email Address..."}
  validates :email, :format => { with: VALID_EMAIL_REGEX, :message => "Email Address should be like 'user@example.com'..." }
  validates :email, :uniqueness => { case_sensitive: false, :message => "Looks like someone has already registered with this Email Address..." }

  validates :password, :presence => { :message => "Looks like you didn't pick a password..."}
  validates :password, :length => { minimum: 8, :message => "Looks like your password is a bit too short..."}
  validates :password_confirmation, :presence => { :message => "Looks like you didn't confirm your password..."}

  def user_request_feed
    RequestDelivery.where("user_id = ?", id)
  end

  def user_suggest_feed
    SuggestDelivery.where("user_id = ?", id)
  end

  def mailboxer_email(message)
    email
  end

  def send_email_confirmation_request
    generate_token(:email_confirmation_token)
    save!(validate: false)
    NotifMailer.confirmation_email(self).deliver
  end

  def send_email_confirmation_request_no_token
    NotifMailer.confirmation_email(self).deliver
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!(validate: false)
    NotifMailer.password_reset(self).deliver
  end

  def confirm_user
    self.update_attribute(:email_confirmed,true)
  end

  def add_review
    positive_sender_reviews = UserReview.where('to_user_id = ? AND job_type = ? AND pos_or_neg = ?',self.id,"SENDER","POSITIVE").count.to_i
    negative_sender_reviews = UserReview.where('to_user_id = ? AND job_type = ? AND pos_or_neg = ?',self.id,"SENDER","NEGATIVE").count.to_i
    total_sender_reviews = positive_sender_reviews + negative_sender_reviews
    if total_sender_reviews > 0
      sender_rating = 100 * positive_sender_reviews / total_sender_reviews
      self.update_attribute(:sender_rating, sender_rating)
    end

    positive_transporter_reviews = UserReview.where('to_user_id = ? AND job_type = ? AND pos_or_neg = ?',self.id,"TRANSPORTER","POSITIVE").count.to_i
    negative_transporter_reviews = UserReview.where('to_user_id = ? AND job_type = ? AND pos_or_neg = ?',self.id,"TRANSPORTER","NEGATIVE").count.to_i
    total_transporter_reviews = positive_transporter_reviews + negative_transporter_reviews
    if total_transporter_reviews > 0
      transporter_rating = 100 * positive_transporter_reviews / total_transporter_reviews
      self.update_attribute(:transporter_rating, transporter_rating)
    end
  end

  def sender_reviews
    UserReview.find_all_by_to_user_id_and_job_type(self.id,"SENDER")
  end

  def transporter_reviews
    UserReview.find_all_by_to_user_id_and_job_type(self.id,"TRANSPORTER")
  end

  def verified_phone
    phone = Phone.find_by_user_id(self.id)
    phone.verified
  end

  def phone
     Phone.find_by_user_id(self.id).phone
  end

  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end



end
