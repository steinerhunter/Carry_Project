class CreateAcceptedRequests < ActiveRecord::Migration
  def change
    create_table :accepted_requests do |t|
      t.integer :request_delivery_id
      t.integer :user_id

      t.timestamps
    end
    add_index :accepted_requests, :request_delivery_id
    add_index :accepted_requests, :user_id
    add_index :accepted_requests, [:request_delivery_id, :user_id], unique: true
  end
end
