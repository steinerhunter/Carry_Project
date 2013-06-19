class AddSizeToSuggestDeliveries < ActiveRecord::Migration
  def change
    add_column :suggest_deliveries, :size, :string
  end
end
