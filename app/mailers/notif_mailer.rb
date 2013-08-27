class NotifMailer < ActionMailer::Base
  default from: "sendwithme@sendwith.me"

  def password_reset(user)
    @user = user
    mail(:to => user.email, :subject => "Password Reset Instructions")
  end

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

  def new_complete_request(creating_user,accepting_user,request_delivery)
    @creating_user = creating_user
    @accepting_user = accepting_user
    @request_delivery = request_delivery
    mail(:to => @creating_user.email, :subject => "#{accepting_user.name} has completed your request!")
  end

  def new_accepted_suggest(creating_user,accepting_user,suggest_delivery)
    @creating_user = creating_user
    @accepting_user = accepting_user
    @suggest_delivery = suggest_delivery
    mail(:to => @creating_user.email, :subject => "#{accepting_user.name} has accepted your suggestion!")
  end

  def new_confirmed_suggest(creating_user,accepting_user,suggest_delivery)
    @creating_user = creating_user
    @accepting_user = accepting_user
    @suggest_delivery = suggest_delivery
    mail(:to => @accepting_user.email, :subject => "#{creating_user.name} has confirmed you for their suggestion!")
  end

  def new_complete_suggest(creating_user,accepting_user,suggest_delivery)
    @creating_user = creating_user
    @accepting_user = accepting_user
    @suggest_delivery = suggest_delivery
    mail(:to => @accepting_user.email, :subject => "#{creating_user.name} has completed their suggestion!")
  end

end
