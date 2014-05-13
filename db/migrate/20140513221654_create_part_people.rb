class CreatePartPeople < ActiveRecord::Migration
  def change
    create_table :part_people do |t|
      t.integer :working_group_id
      t.string :number_part
      t.date :date_of_creation

      t.timestamps
    end
  end
end
