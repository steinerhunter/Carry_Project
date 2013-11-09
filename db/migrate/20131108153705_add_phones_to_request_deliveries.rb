class AddPhonesToRequestDeliveries < ActiveRecord::Migration
  def change
    add_column :request_deliveries, :sending_phone, :string
    add_column :request_deliveries, :receiving_phone, :string
  end
end
