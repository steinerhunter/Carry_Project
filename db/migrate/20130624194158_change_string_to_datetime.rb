class ChangeStringToDatetime < ActiveRecord::Migration
  def up
    change_column :request_deliveries, :when, :datetime
    change_column :suggest_deliveries, :when, :datetime
  end

  def down
    change_column :request_deliveries, :when, :string
    change_column :suggest_deliveries, :when, :string
  end
end
