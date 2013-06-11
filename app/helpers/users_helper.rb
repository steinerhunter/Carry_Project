module UsersHelper
  # Returns a Gravatar for a given user (Thanks to http://gravatar.com)
  def gravatar_for(user)

      gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
      gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?d=wavatar"

    image_tag(gravatar_url, alt: user.name, class:"gravatar")
  end

end