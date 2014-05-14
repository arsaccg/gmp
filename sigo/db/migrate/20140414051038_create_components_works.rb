class CreateComponentsWorks < ActiveRecord::Migration
  def change
    create_table :components_works do |t|
      t.integer :work_id
      t.integer :component_id

      t.timestamps
    end
    add_index :components_works, [:work_id, :component_id]
  end
end
