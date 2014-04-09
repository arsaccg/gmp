class CreateStockInputs < ActiveRecord::Migration
  def change
    create_table :stock_inputs do |t|
      t.references :warehouse, index: true
      t.integer :supplier_id
      t.integer :period
      t.string :series
      t.string :document
      t.references :format, index: true
      t.date :issue_date
      t.string :description
      t.string :status
      t.integer :user_inserts_id
      t.integer :user_updates_id

      t.timestamps
    end
  end
end
