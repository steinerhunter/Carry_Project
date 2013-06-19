class AddSizeToRequestDeliveries < ActiveRecord::Migration
  def change
    add_column :request_deliveries, :size, :string
  end
end
