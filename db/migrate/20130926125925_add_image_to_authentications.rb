class AddImageToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :image, :string
  end
end
