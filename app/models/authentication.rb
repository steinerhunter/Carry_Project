class Authentication < ActiveRecord::Base

  PROVIDER = ["facebook"]

  # associations
  #
  #

  belongs_to :user

  # validations
  #
  #

  validate :uid, :presence => true, :uniqueness => { :scope => :provider }

  # attributes
  #
  #

  attr_accessible :provider, :uid, :image

end