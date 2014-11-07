class AddColumnsToCategoryOfWorkerConcepts < ActiveRecord::Migration
  def change
  	add_column :category_of_workers_concepts, :category_of_worker_id, :integer
    add_column :category_of_workers_concepts, :concept_id, :integer
    add_column :category_of_workers_concepts, :amount, :string
    add_column :category_of_workers_concepts, :type_concept, :string
  end
end
