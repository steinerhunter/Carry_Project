class AddCompleteToAcceptedSuggests < ActiveRecord::Migration
  def change
    add_column :accepted_suggests, :complete, :boolean, :default => false
  end
end
