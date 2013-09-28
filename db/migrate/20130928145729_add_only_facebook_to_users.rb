class AddOnlyFacebookToUsers < ActiveRecord::Migration
  def change
    add_column :users, :only_facebook, :boolean, :default => false
  end
end
