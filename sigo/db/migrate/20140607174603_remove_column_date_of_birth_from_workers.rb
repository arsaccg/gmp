class RemoveColumnDateOfBirthFromWorkers < ActiveRecord::Migration
  def change
  	remove_column :workers, :date_of_birth
  end
end
