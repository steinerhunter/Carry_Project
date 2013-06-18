class AddCostToRequestDeliveries < ActiveRecord::Migration
  def change
    add_column :request_deliveries, :cost, :string
  end
end
