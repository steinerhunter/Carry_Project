class AddDistanceToRequestDeliveries < ActiveRecord::Migration
  def change
    add_column :request_deliveries, :distance_text, :string
    add_column :request_deliveries, :distance_value, :integer
  end
end
