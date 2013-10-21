class AddRatingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sender_rating, :integer
    add_column :users, :transporter_rating, :integer
  end
end
