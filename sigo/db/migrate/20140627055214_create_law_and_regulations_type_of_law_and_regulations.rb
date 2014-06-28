class CreateLawAndRegulationsTypeOfLawAndRegulations < ActiveRecord::Migration
  def change
    create_table :law_and_regulations_type_of_law_and_regulations do |t|
      t.integer :law_and_regulation_id
      t.integer :type_of_law_and_regulation_id

      t.timestamps
    end
  end
end
