class AddstateToweeklyTable < ActiveRecord::Migration
  def change
  	add_column :weekly_tables, :state, :string if table_exists? :weekly_tables
  end
end
