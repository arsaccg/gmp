class CreatePartOfEquipments < ActiveRecord::Migration
  def change
    create_table :part_of_equipments do |t|
      t.integer :code
      t.integer :entity_id
      t.integer :equipment
      t.integer :worker_id
      t.string :hour_meter
      t.string :mileage
      t.string :dif
      t.integer :h_stand_by
      t.integer :h_maintenance
      t.float :fuel_amount
      t.integer :sub_group_id
      t.date :date
      t.float :total_hours

      t.timestamps
    end
  end
end
