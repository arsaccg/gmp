class CreateConceptValorizations < ActiveRecord::Migration
  def change
    create_table :concept_valorizations do |t|
      t.integer :concept_id
      t.date :date_week
      t.integer :cost_center_id
      t.integer :concept_reference_id
      t.string :amount

      t.timestamps
    end
  end
end
