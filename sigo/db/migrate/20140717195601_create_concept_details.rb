class CreateConceptDetails < ActiveRecord::Migration
  def change
    create_table :concept_details do |t|
      t.integer :concept_id
      t.integer :subconcept_id
      t.string :category
      t.integer :status

      t.timestamps
    end
  end
end
