class CreateValorizationByCategories < ActiveRecord::Migration
  def change
    create_table :valorization_by_categories do |t|
      t.integer :valorization_id
      t.string :category_id
      t.float :amount
      t.integer :budget_id

      t.timestamps
    end
  end
end
