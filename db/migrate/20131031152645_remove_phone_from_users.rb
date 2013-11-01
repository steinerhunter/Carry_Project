class RemovePhoneFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :phone
    remove_column :users, :verified_phone
  end

  def down
    add_column :users, :phone, :string
    add_column :users, :verified_phone, :boolean, :default => false
  end
end
