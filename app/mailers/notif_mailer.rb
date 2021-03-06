class NotifMailer < ActionMailer::Base
  default from: "support@sendd.me"

  def confirmation_email(user)
    @user = user
    mail(:to => user.email, :subject => "Email Address Confirmation")
  end

  def password_reset(user)
    @user = user
    mail(:to => user.email, :subject => "Password Reset Instructions")
  end

  def new_comment(creating_user,commenting_user,request_delivery)
    @creating_user = creating_user
    @commenting_user = commenting_user
    @request_delivery = request_delivery
    mail(:to => @creating_user.email, :subject => "#{@commenting_user.name} has commented on your giveaway!")
  end

  def new_taken_giveaway(creating_user,taking_user,request_delivery)
    @creating_user = creating_user
    @taking_user = taking_user
    @request_delivery = request_delivery
    mail(:to => @creating_user.email, :subject => "#{@taking_user.name} is interested in your giveaway!")
  end

  def new_taken_confirmed_senddme(creating_user,taking_user,request_delivery)
    @creating_user = creating_user
    @taking_user = taking_user
    @request_delivery = request_delivery
    mail(:to => @creating_user.email, :subject => "#{@taking_user.name} has confirmed their details!")
  end

  def new_taken_confirmed_self(creating_user,taking_user,request_delivery)
    @creating_user = creating_user
    @taking_user = taking_user
    @request_delivery = request_delivery
    mail(:to => @creating_user.email, :subject => "#{@taking_user.name} has confirmed their details!")
  end

  def another_user(creating_user,taking_user,request_delivery)
    @creating_user = creating_user
    @taking_user = taking_user
    @request_delivery = request_delivery
    mail(:to => @taking_user.email, :subject => "#{@creating_user.name} wants to give their item to someone else.")
  end

  def new_accepted_request(creating_user,accepting_user,request_delivery)
    @creating_user = creating_user
    @accepting_user = accepting_user
    @request_delivery = request_delivery
    mail(:to => @creating_user.email, :subject => "#{@accepting_user.name} has accepted your request!")
  end

  def new_confirmed_request(creating_user,accepting_user,request_delivery)
    @creating_user = creating_user
    @accepting_user = accepting_user
    @request_delivery = request_delivery
    mail(:to => @accepting_user.email, :subject => "#{@creating_user.name} has confirmed you for their request!")
  end

  def new_complete_request(creating_user,accepting_user,request_delivery)
    @creating_user = creating_user
    @accepting_user = accepting_user
    @request_delivery = request_delivery
    mail(:to => @creating_user.email, :subject => "#{@accepting_user.name} has completed your request!")
  end

  def new_accepted_suggest(creating_user,accepting_user,suggest_delivery)
    @creating_user = creating_user
    @accepting_user = accepting_user
    @suggest_delivery = suggest_delivery
    mail(:to => @creating_user.email, :subject => "#{@accepting_user.name} has accepted your suggestion!")
  end

  def new_confirmed_suggest(creating_user,accepting_user,suggest_delivery)
    @creating_user = creating_user
    @accepting_user = accepting_user
    @suggest_delivery = suggest_delivery
    mail(:to => @accepting_user.email, :subject => "#{@creating_user.name} has confirmed you for their suggestion!")
  end

  def new_authorized_suggest(creating_user,accepting_user,suggest_delivery)
    @creating_user = creating_user
    @accepting_user = accepting_user
    @suggest_delivery = suggest_delivery
    mail(:to => @accepting_user.email, :subject => "#{@creating_user.name} has authorized payment for your suggestion!")
  end

  def new_complete_suggest(creating_user,accepting_user,suggest_delivery)
    @creating_user = creating_user
    @accepting_user = accepting_user
    @suggest_delivery = suggest_delivery
    mail(:to => @accepting_user.email, :subject => "#{@creating_user.name} has completed their suggestion!")
  end

end
