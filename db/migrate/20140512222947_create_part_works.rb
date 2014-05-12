class CreatePartWorks < ActiveRecord::Migration
  def change
    create_table :part_works do |t|
      t.integer :working_group_id
      t.string :number_working_group
      t.integer :sector_id
      t.date :date_of_creation

      t.timestamps
    end
  end
end
