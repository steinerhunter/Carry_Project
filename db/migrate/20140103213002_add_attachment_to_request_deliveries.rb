class AddAttachmentToRequestDeliveries < ActiveRecord::Migration
  def change
    add_column :request_deliveries, :attachment, :string
  end
end
