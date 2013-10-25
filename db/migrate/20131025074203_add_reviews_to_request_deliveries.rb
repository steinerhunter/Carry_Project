class AddReviewsToRequestDeliveries < ActiveRecord::Migration
  def change
    add_column :request_deliveries, :sender_reviewed, :boolean, :default => false
    add_column :request_deliveries, :transporter_reviewed, :boolean, :default => false
  end
end
