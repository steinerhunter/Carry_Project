class AddReviewsToSuggestDeliveries < ActiveRecord::Migration
  def change
    add_column :suggest_deliveries, :sender_reviewed, :boolean, :default => false
    add_column :suggest_deliveries, :transporter_reviewed, :boolean, :default => false
  end
end
