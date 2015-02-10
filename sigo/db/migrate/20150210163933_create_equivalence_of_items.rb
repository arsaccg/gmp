class CreateEquivalenceOfItems < ActiveRecord::Migration
  def change
    create_table :equivalence_of_items do |t|
      t.integer :sale_item_by_budget_id
      t.integer :target_item_by_budget_id
      t.column :percentage,        :float,   :limit => 25

      t.timestamps
    end
  end
end
