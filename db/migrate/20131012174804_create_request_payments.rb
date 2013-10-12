class CreateRequestPayments < ActiveRecord::Migration
  def change
    create_table :request_payments do |t|
      t.integer :request_delivery_id
      t.integer :user_id
      t.string :payKey

      t.timestamps
    end
    add_index :request_payments, :request_delivery_id
    add_index :request_payments, :user_id
    add_index :request_payments, [:request_delivery_id, :user_id], unique: true
  end
end
