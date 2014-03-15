class AddGeneralCategoryToRequestDeliveries < ActiveRecord::Migration
  def change
    add_column :request_deliveries, :general_category, :string
  end
end
