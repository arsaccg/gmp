class CreateLinkPeriods < ActiveRecord::Migration
  def change
    create_table :link_periods do |t|
      t.references :cost_center, index: true
      t.date :date
      t.integer :year
      t.integer :month
      t.integer :day
      t.integer :week

      t.timestamps
    end
  end
end
