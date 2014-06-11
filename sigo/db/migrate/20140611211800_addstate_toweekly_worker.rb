class AddstateToweeklyWorker < ActiveRecord::Migration
  def change
  	add_column :weekly_workers, :state, :string
  end
end
