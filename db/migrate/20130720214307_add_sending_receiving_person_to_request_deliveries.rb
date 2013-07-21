class AddSendingReceivingPersonToRequestDeliveries < ActiveRecord::Migration
  def change
    add_column :request_deliveries, :sending_person, :string
    add_column :request_deliveries, :receiving_person, :string
  end
end
