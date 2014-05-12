class CreateComponetsOtherWorks < ActiveRecord::Migration
  def change
    create_table :componets_other_works do |t|
      t.integer :component_id
      t.integer :other_works_id

      t.timestamps
    end
  end
end
