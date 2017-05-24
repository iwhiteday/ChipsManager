class CreateBalances < ActiveRecord::Migration[5.1]
  def change
    create_table :balances do |t|
      t.string :currency
      t.decimal :amount, precision: 8, scale: 2
    end
  end
end
