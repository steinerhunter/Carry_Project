class AddStatusToSuggestDelivery < ActiveRecord::Migration
  def change
    add_column :suggest_deliveries, :status, :string, :default => "Open"
  end
end
