class AddHasAllDetailsToRequestDeliveries < ActiveRecord::Migration
  def change
    add_column :request_deliveries, :has_all_details, :boolean, :default => false
  end
end
