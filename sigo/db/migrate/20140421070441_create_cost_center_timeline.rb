class CreateCostCenterTimeline < ActiveRecord::Migration
  def change
    create_table :cost_center_timelines do |t|
      t.references :cost_center, index: true
      t.date :date
      t.integer :year
      t.integer :period
      t.integer :week
      t.integer :day
    end
  end
end
