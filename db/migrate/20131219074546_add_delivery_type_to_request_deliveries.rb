class AddDeliveryTypeToRequestDeliveries < ActiveRecord::Migration
  def change
    add_column :request_deliveries, :delivery_type, :string
  end
end
