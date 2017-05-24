class CreateChips < ActiveRecord::Migration[5.1]
  def change
    create_table :chips do |t|
      t.integer :value
      t.integer :count
    end
  end
end
