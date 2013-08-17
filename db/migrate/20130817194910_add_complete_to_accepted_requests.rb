class AddCompleteToAcceptedRequests < ActiveRecord::Migration
  def change
    add_column :accepted_requests, :complete, :boolean, :default => false
  end
end
