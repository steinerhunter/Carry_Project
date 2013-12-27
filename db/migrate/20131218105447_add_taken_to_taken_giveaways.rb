class AddTakenToTakenGiveaways < ActiveRecord::Migration
  def change
    add_column :taken_giveaways, :taken, :bool, :default => false
  end
end
