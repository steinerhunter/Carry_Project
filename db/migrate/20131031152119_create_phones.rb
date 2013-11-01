class CreatePhones < ActiveRecord::Migration
  def change
    create_table :phones do |t|
      t.integer :user_id
      t.string :phone
      t.integer :verification_code
      t.boolean :verified, :default => false

      t.timestamps
    end
    add_index :phones, :user_id, unique: true
  end
end
