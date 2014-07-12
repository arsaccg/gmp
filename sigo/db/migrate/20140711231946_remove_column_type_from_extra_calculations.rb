class RemoveColumnTypeFromExtraCalculations < ActiveRecord::Migration
  def change
    remove_column :extra_calculations, :type
  end
end
