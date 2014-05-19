class CreateValorizations < ActiveRecord::Migration
  def change
    create_table :valorizations do |t|
      t.string :month
      t.string :name
      t.string :status
      t.integer :budget_id

      t.timestamps
    end
  end
end
