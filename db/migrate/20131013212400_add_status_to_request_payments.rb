class AddStatusToRequestPayments < ActiveRecord::Migration
  def change
    add_column :request_payments, :status, :string
  end
end
