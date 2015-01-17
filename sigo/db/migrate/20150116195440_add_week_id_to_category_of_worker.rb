class AddWeekIdToCategoryOfWorker < ActiveRecord::Migration
  def change
    add_column :category_of_workers, :week_id, :integer
    add_column :category_of_workers, :cost_center_id, :integer
  end
end
