class AddConfirmedToAcceptedRequests < ActiveRecord::Migration
  def change
    add_column :accepted_requests, :confirmed, :boolean, :default => false
  end
end
