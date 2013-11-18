class AddFrequencyToSuggestDeliveries < ActiveRecord::Migration
  def change
    add_column :suggest_deliveries, :frequency, :string
  end
end
