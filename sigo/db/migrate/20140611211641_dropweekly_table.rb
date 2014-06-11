class DropweeklyTable < ActiveRecord::Migration
  def change
  	drop_table :weekly_tables if table_exists? :weekly_tables
  end
end
