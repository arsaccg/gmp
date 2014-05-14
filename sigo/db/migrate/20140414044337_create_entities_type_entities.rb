class CreateEntitiesTypeEntities < ActiveRecord::Migration
  def change
    create_table :entities_type_entities do |t|
      t.integer :entity_id
      t.integer :type_entity_id

      t.timestamps
    end
    add_index :entities_type_entities, [:entity_id, :type_entity_id]
  end
end
