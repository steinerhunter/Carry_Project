class CreateAcceptedSuggests < ActiveRecord::Migration
  def change
    create_table :accepted_suggests do |t|
      t.integer :suggest_delivery_id
      t.integer :user_id

      t.timestamps
    end
    add_index :accepted_suggests, :suggest_delivery_id
    add_index :accepted_suggests, :user_id
    add_index :accepted_suggests, [:suggest_delivery_id, :user_id], unique: true
  end
end