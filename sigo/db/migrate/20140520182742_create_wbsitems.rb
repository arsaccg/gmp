class CreateWbsitems < ActiveRecord::Migration
  def change
    create_table :wbsitems do |t|
      t.string :codewbs
      t.string :name
      t.string :description
      t.string :notes
      t.integer :cost_center_id
      t.datetime :start_date
      t.datetime :end_date
      t.string :predecessors
      t.string :fase_id
      t.string :fase

      t.timestamps
    end
  end
end
