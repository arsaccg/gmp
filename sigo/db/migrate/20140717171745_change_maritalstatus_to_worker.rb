class ChangeMaritalstatusToWorker < ActiveRecord::Migration
  def change
  	add_column :workers, :driverlicense, :string
  	add_column :workers, :maritalstatus, :string
  	remove_column :entities, :driverlicense
  	remove_column :entities, :maritalstatus
  end
end
