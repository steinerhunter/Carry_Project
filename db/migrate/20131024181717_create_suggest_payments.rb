class CreateSuggestPayments < ActiveRecord::Migration
  def change
    create_table :suggest_payments do |t|
      t.integer :suggest_delivery_id
      t.integer :user_id
      t.string :preapprovalKey
      t.string :status

      t.timestamps
    end
    add_index :suggest_payments, :suggest_delivery_id
    add_index :suggest_payments, :user_id
    add_index :suggest_payments, [:suggest_delivery_id, :user_id], unique: true
  end
end
