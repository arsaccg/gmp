class CreateBudgets < ActiveRecord::Migration
  def change
    create_table :budgets do |t|
      t.string :cod_budget #codigo de presupuesto
      t.string :description #descripcion
      t.integer :term 
      t.timestamps
    end
  end
end
