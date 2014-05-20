class CreateInputbybudgetanditems < ActiveRecord::Migration
  def change
    create_table :inputbybudgetanditems do |t|
      t.string :coditem
      t.string :ownitem
      t.string :cod_input
      t.float :quantity
      t.float :price
      t.float :aprox
      t.string :order
      t.float :measured
      t.string :input
      t.integer :budget_id
      t.string :subbudget_code
      t.integer :item_id
      t.integer :deleted
      t.string :budget_code
      t.string :owneritem
      t.string :unit

      t.timestamps
    end

    add_index "inputbybudgetanditems", ["cod_input"], name: "cod_input_index", using: :btree
    add_index "inputbybudgetanditems", ["cod_input"], name: "inputbybudgetanditems_codinput", using: :btree
    add_index "inputbybudgetanditems", ["id"], name: "inputbybudgets_id", using: :btree
    add_index "inputbybudgetanditems", ["item_id"], name: "inputbybudgets_item_id", using: :btree
    add_index "inputbybudgetanditems", ["order"], name: "inputbybudgets_order", using: :btree
  end
end
