class CreateValorizations < ActiveRecord::Migration
  def change
    create_table :valorizations do |t|
      t.string :month
      t.string :name
      t.string :status
      t.integer :budget_id
      t.float :general_expenses
      t.float :utility
      t.float :readjustment
      t.float :no_direct_r
      t.float :no_materials_r
      t.float :direct_advance
      t.float :advance_of_materials
      t.date :valorization_date

      t.timestamps
    end
  end
end
