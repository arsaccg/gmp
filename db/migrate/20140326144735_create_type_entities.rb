class CreateTypeEntities < ActiveRecord::Migration
  def change
    create_table :type_entities do |t|
      t.string :name
      t.string :preffix

      t.timestamps
    end
  end
end
