class CreateItembybudgets < ActiveRecord::Migration
  def change
    create_table :itembybudgets do |t|
      t.string :item_code
      t.string :order
      t.string :measured
      t.float :price
      t.float :partial
      t.string :subbudget_code
      t.string :budget_code
      t.integer :budget_id
      t.integer :item_id
      t.integer :deleted
      t.timestamps
    end
  end
end
