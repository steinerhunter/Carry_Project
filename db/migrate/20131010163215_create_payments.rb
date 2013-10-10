class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :status
      t.integer :amount
      t.string :transaction_number

      t.timestamps
    end
  end
end
