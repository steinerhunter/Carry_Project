class AddConditionToRequestDeliveries < ActiveRecord::Migration
  def change
    add_column :request_deliveries, :condition, :string
  end
end
