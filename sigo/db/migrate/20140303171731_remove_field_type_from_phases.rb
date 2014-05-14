class RemoveFieldTypeFromPhases < ActiveRecord::Migration
  def change
    remove_column :phases, :type, :string
  end
end
