class FixColumnConceptValirzation < ActiveRecord::Migration
  def change
  	change_column :concept_valorizations, :type_worker, :integer
  end
end
