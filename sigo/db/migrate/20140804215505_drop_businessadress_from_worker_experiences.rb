class DropBusinessadressFromWorkerExperiences < ActiveRecord::Migration
  def change
  	remove_column :worker_experiences, :businessaddress
  end
end
