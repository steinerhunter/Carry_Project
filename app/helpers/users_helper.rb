module UsersHelper
  # Returns a Gravatar for a given user (Thanks to http://gravatar.com)
  def gravatar_for(user)
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=100&d=wavatar"
    image_tag(gravatar_url, alt: user.name, class:"gravatar")
  end

  def chat_gravatar_for(user)
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=50&d=wavatar"
    image_tag(gravatar_url, alt: user.name, class:"gravatar")
  end

  def header_gravatar_for(user)
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=30&d=wavatar"
    image_tag(gravatar_url, alt: user.name, class:"header_gravatar")
  end

  def facebook_authorization(user)
    user.authentications.where("provider = ?","facebook").where("verified = ?",true).present?
  end

  def facebook_profile_photo(user,type)
    photo_url = user.authentications.where(:provider => "facebook").where(:verified => true).pluck(:image)
    if type == "header"
      split_photo_url = photo_url[0].split("?")[0] << "?width=20&height=20"
      image_tag(split_photo_url, alt: current_user.name, class:"header_facebook_image")
    elsif type == "chat"
      split_photo_url = photo_url[0].split("?")[0] << "?width=50&height=50"
      image_tag(split_photo_url, alt: current_user.name, class:"facebook_image")
    elsif type == "profile"
      split_photo_url = photo_url[0].split("?")[0] << "?width=100&height=100"
      image_tag(split_photo_url, alt: current_user.name, class:"facebook_image")
    end
  end

end