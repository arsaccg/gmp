class CreatePartPersonDetails < ActiveRecord::Migration
  def change
    create_table :part_person_details do |t|
      t.integer :part_people_id
      t.integer :worker_id
      t.integer :sector_id
      t.integer :phase_id
      t.integer :normal_hours
      t.integer :he_60
      t.integer :he_100
      t.integer :total_hours

      t.timestamps
    end
  end
end
