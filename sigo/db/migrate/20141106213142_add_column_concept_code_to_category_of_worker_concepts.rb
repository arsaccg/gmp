class AddColumnConceptCodeToCategoryOfWorkerConcepts < ActiveRecord::Migration
  def change
  	add_column :category_of_workers_concepts, :concept_code, :string
  end
end
