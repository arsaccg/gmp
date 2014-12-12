class AddColumnTypeToConceptValorizations < ActiveRecord::Migration
  def change
    add_column :concept_valorizations, :type_worker, :string
  end
end
