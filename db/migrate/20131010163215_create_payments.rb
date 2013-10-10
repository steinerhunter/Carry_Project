class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :status
      t.string :amount
      t.string :transaction_number

      t.timestamps
    end
  end
end
