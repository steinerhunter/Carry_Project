class AddSpecificCategoryToRequestDeliveries < ActiveRecord::Migration
  def change
    add_column :request_deliveries, :specific_category, :string
  end
end
