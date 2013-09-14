class AddEmailConfirmationTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_confirmation_token, :string
    add_column :users, :email_confirmed, :boolean, :default => false
  end
end
