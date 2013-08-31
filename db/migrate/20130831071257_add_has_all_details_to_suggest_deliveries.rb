class AddHasAllDetailsToSuggestDeliveries < ActiveRecord::Migration
  def change
    add_column :suggest_deliveries, :has_all_details, :boolean, :default => false
  end
end
