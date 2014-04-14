class DropEntityPerTypeEntitiesTable < ActiveRecord::Migration
  def change
   drop_table :entity_per_type_entities
  end
end
