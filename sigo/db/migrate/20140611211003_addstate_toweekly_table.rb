class AddstateToweeklyTable < ActiveRecord::Migration
  def change
  	add_column :weekly_tables, :state, :string
  end
end
