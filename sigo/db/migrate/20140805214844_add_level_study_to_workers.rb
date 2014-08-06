class AddLevelStudyToWorkers < ActiveRecord::Migration
  def change
  	add_column :workers,:lastgrade, :string
  end
end
