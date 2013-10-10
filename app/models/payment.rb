class Payment < ActiveRecord::Base
  PROCESSING, FAILED, SUCCESS = 1, 2, 3

  validates :amount, :presence => { :message => "OOPS! Looks like you didn't type any amount..."}
  validates :amount, :numericality => { :only_integer => true, :message => "Only whole numbers please..." }

  def self.conf
    @@gateway_conf ||= YAML.load_file(Rails.root.join('config/gateway.yml').to_s)[Rails.env]
  end

  ## Paypal
  def setup_purchase(options)
    gateway.setup_purchase(amount * 100, options)
  end

  def redirect_url_for(token)
    gateway.redirect_url_for(token)
  end

  def purchase(options={})
    self.status = PROCESSING
    #:ip       => request.remote_ip,
    #:payer_id => params[:payer_id],
    #:token    => params[:token]
    response = gateway.purchase(amount, options)
    if response.success?
      self.transaction_num = response.params['transaction_id']
      self.status = SUCCESS
    else
      self.status = FAILED
    end
    return self
  rescue Exception => e
    self.status = FAILED
    return self
  end

  private
  def gateway
    ActiveMerchant::Billing::Base.mode = auth['mode'].to_sym
    ActiveMerchant::Billing::PaypalExpressGateway.new(
        :login => auth['login'], :password => auth['password'],
        :signature => auth['signature'])
  end

  def auth
    self.class.conf
  end
end
