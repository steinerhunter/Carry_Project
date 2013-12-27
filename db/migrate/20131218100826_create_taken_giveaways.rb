class CreateTakenGiveaways < ActiveRecord::Migration
  def change
    create_table :taken_giveaways do |t|
      t.integer :request_delivery_id
      t.integer :user_id

      t.timestamps
    end
    add_index :taken_giveaways, :request_delivery_id
    add_index :taken_giveaways, :user_id
    add_index :taken_giveaways, [:request_delivery_id, :user_id], unique: true
  end
end
