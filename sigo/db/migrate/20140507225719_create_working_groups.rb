class CreateWorkingGroups < ActiveRecord::Migration
  def change
    create_table :working_groups do |t|
      t.integer :sector_id
      t.integer :master_builder_id
      t.integer :front_chief_id
      t.boolean :active

      t.timestamps
    end
  end
end
