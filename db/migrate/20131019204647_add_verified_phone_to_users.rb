class AddVerifiedPhoneToUsers < ActiveRecord::Migration
  def change
    add_column :users, :verified_phone, :boolean, :default => false
  end
end
