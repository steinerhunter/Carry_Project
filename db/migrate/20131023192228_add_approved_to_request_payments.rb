class AddApprovedToRequestPayments < ActiveRecord::Migration
  def change
    add_column :request_payments, :approved, :boolean, :default => false
  end
end
