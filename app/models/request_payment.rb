class RequestPayment < ActiveRecord::Base
  attr_accessible :user_id, :transaction_id, :payKey
end
