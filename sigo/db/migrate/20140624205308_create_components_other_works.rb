class CreateComponentsOtherWorks < ActiveRecord::Migration
  def change
    create_table :components_other_works do |t|
      t.integer :other_work_id
      t.integer :component_id

      t.timestamps
    end
  end
end
