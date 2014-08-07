class CreateFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.integer :folderfa_id
      t.string :name
      t.string :description
      t.integer :cost_center_id

      t.timestamps
    end
  end
end
