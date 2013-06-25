class CreateSuggestDeliveries < ActiveRecord::Migration
  def change
    create_table :suggest_deliveries do |t|
      t.string :from
      t.string :to
      t.datetime :when
      t.string :more_details
      t.integer :user_id

      t.timestamps
    end
    add_index :suggest_deliveries, [:user_id, :created_at]
  end
end
