class CreateSpecifics < ActiveRecord::Migration
  def change
    create_table :specifics do |t|
      t.integer :subcategory_id
      t.integer :code
      t.string :name

      t.timestamps
    end
  end
end
