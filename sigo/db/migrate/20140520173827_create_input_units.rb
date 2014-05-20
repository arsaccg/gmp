class CreateInputUnits < ActiveRecord::Migration
  def change
    create_table :input_units do |t|
      t.integer :unit_id
      t.integer :input_id
      t.string :code

      t.timestamps
    end
  end
end
