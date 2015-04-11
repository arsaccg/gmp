class AddColumnsToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :start_date, :date
    add_column :workers, :end_date, :date
  end
end
