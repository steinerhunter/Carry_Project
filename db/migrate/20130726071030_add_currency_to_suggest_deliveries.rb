class AddCurrencyToSuggestDeliveries < ActiveRecord::Migration
  def change
    add_column :suggest_deliveries, :currency, :string
  end
end
