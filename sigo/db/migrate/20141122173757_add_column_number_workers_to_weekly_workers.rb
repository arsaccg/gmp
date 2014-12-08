class AddColumnNumberWorkersToWeeklyWorkers < ActiveRecord::Migration
  def change
    add_column :weekly_workers, :number_workers, :string
  end
end
