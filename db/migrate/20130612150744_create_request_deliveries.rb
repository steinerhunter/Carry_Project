class CreateRequestDeliveries < ActiveRecord::Migration
  def change
    create_table :request_deliveries do |t|
      t.string :from
      t.string :to
      t.string :when
      t.string :more_details
      t.integer :user_id

      t.timestamps
    end
    add_index :request_deliveries, [:user_id, :created_at]
  end
end
