class NotifMailer < ActionMailer::Base
  default from: "sendwithme@sendwith.me"

  def new_accepted_request(creating_user,accepting_user)
    @creating_user = creating_user
    @accepting_user = accepting_user
    mail(:to => @creating_user.email, :subject => "#{accepting_user.name} has accepted your request!")
  end


end
