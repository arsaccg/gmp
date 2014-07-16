class RenamecountryFromWorkers < ActiveRecord::Migration
  def change
  	rename_column(:workers, :country, :pais)
  end
end
