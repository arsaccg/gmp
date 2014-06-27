class CreateTypeOfLawAndRegulations < ActiveRecord::Migration
  def change
    create_table :type_of_law_and_regulations do |t|
      t.string :name
      t.string :preffix

      t.timestamps
    end
  end
end
