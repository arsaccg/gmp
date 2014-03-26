class CreateEntities < ActiveRecord::Migration
  def change
    create_table :entities do |t|
      t.string :name
      t.string :surname
      t.string :dni
      t.string :ruc

      t.timestamps
    end
  end
end
