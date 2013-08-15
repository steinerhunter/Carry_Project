class AddConfirmedToAcceptedSuggests < ActiveRecord::Migration
  def change
    add_column :accepted_suggests, :confirmed, :boolean, :default => false
  end
end
