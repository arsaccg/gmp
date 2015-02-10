class ChangeColumnWeekIdToChangeDateFromCategoryOfWorker < ActiveRecord::Migration
  def change
  	rename_column :category_of_workers, :week_id, :change_date
  	change_column :category_of_workers, :change_date, :date  	
  end
end
