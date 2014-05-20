class CreateItembybudgets < ActiveRecord::Migration
  def change
    create_table :itembybudgets do |t|
      t.string :item_code
      t.string :order
      t.float :measured
      t.float :price
      t.float :partial
      t.string :subbudget_code
      t.string :budget_code
      t.integer :budget_id
      t.integer :item_id
      t.integer :deleted
      t.string :title
      t.string :subbudgetdetail
      t.string :owneritem

      t.timestamps
    end

    add_index "itembybudgets", ["item_id"], name: "itembybudges_item_id", using: :btree
  end
end
