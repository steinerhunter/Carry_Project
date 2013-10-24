class AddApprovedToSuggestPayments < ActiveRecord::Migration
  def change
    add_column :suggest_payments, :approved, :boolean, :default => false
  end
end
