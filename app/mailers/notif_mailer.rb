class NotifMailer < ActionMailer::Base
  default from: "sendwithme@sendwith.me"

  def new_accepted_request(creating_user,accepting_user,request_delivery)
    @creating_user = creating_user
    @accepting_user = accepting_user
    @request_delivery = request_delivery
    mail(:to => @creating_user.email, :subject => "#{accepting_user.name} has accepted your request!")
  end

  def new_confirmed_request(creating_user,accepting_user,request_delivery)
    @creating_user = creating_user
    @accepting_user = accepting_user
    @request_delivery = request_delivery
    mail(:to => @accepting_user.email, :subject => "#{creating_user.name} has confirmed you for their request!")
  end

end
