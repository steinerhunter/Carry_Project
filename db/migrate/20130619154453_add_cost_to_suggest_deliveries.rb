class AddCostToSuggestDeliveries < ActiveRecord::Migration
  def change
    add_column :suggest_deliveries, :cost, :string
  end
end
