class CreateEntityPerTypeEntities < ActiveRecord::Migration
  def change
    create_table :entity_per_type_entities do |t|
      t.integer :entity_id
      t.integer :type_entity_id

      t.timestamps
    end
  end
end
