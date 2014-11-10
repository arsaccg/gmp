class AddAndRenameColumnsFromConcepts < ActiveRecord::Migration
  def change
  	rename_column :concepts, :type_concept, :type_obrero
  	add_column :concepts, :type_empleado, :string
  	add_column :concepts, :company_id, :integer
  end
end
