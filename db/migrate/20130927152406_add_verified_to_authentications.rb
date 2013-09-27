class AddVerifiedToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :verified, :boolean, :default => false
  end
end
