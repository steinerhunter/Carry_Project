class AddNormalizedPhoneToPhones < ActiveRecord::Migration
  def change
    add_column :phones, :normalized_phone, :string
  end
end
