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
      t.timestamps
    end
  end
end
