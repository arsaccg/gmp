class CreateWeeksPerCostCenters < ActiveRecord::Migration
  def change
    create_table :weeks_per_cost_centers do |t|
      t.string :name
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
