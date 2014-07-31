class RenamesituationfromWorker < ActiveRecord::Migration
  def change
  	rename_column(:workers, :situation, :state)
  	remove_column :workers, :workday
  end
end
