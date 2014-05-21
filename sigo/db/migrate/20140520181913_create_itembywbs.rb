class CreateItembywbs < ActiveRecord::Migration
  def change
    create_table :itembywbs do |t|
      t.string :wbscode
      t.integer :itembywbs_id
      t.string :coditem
      t.string :order_budget
      t.string :partial
      t.string :subbudget_code
      t.float :price
      t.string :budget_code
      t.integer :budget_id
      t.integer :item_id
      t.string :status_flag
      t.integer :deleted
      t.integer :wbsitem_id
      t.float :measured
      t.integer :cost_center_id
      t.string :subbudgetdetail
      t.integer :itembybudget_id

      t.timestamps
    end
  end
end
