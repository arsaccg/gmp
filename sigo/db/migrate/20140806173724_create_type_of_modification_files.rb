class CreateTypeOfModificationFiles < ActiveRecord::Migration
  def change
    create_table :type_of_modification_files do |t|
      t.string :name
      t.string :preffix
      t.integer :cost_center_id

      t.timestamps
    end
  end
end
