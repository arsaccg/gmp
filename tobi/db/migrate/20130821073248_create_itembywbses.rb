class CreateItembywbses < ActiveRecord::Migration
  def change
    create_table :itembywbses do |t|
      t.string :wbscode
      t.integer :itembywbs_id
      t.string :coditem
      t.string :order_budget
      t.float :price, { :length => 10, :decimals => 2 }
      t.string :partial
      t.string :subbudget_code
      t.string :budget_code
      t.integer :budget_id
      t.integer :item_id
      t.string :status_flag
      t.integer :deleted
      
      t.timestamps
    end
  end
end
