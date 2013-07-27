class AddCurrencyToRequestDeliveries < ActiveRecord::Migration
  def change
    add_column :request_deliveries, :currency, :string
  end
end
