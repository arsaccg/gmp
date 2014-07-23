class AddColumnTypeConceptToConcept < ActiveRecord::Migration
  def change
    add_column :concepts, :type_concept, :string
    add_column :concepts, :status, :integer
  end
end
