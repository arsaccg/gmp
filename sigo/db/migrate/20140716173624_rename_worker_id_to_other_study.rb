class RenameWorkerIdToOtherStudy < ActiveRecord::Migration
  def change
  	rename_column(:worker_familiars, :dateofbirth, :dayofbirth)
  end
end
