class CreateGeneralExpenses < ActiveRecord::Migration
  def change
    create_table :general_expenses do |t|
      t.integer :phase_id
      t.integer :cost_center_id

      t.timestamps
    end
  end
end
