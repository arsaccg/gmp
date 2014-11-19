class AddColumnFormulaToConceptValorizations < ActiveRecord::Migration
  def change
    add_column :concept_valorizations, :formula, :string
  end
end
