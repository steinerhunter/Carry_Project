class AddWhatToRequestDeliveries < ActiveRecord::Migration
  def change
    add_column :request_deliveries, :what, :string
  end
end
