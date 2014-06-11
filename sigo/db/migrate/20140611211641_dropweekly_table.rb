class DropweeklyTable < ActiveRecord::Migration
  def change
  	drop_table :weekly_tables
  end
end
