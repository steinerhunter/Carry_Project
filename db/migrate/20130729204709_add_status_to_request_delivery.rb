class AddStatusToRequestDelivery < ActiveRecord::Migration
  def change
    add_column :request_deliveries, :status, :string, :default => "Open"
  end
end
