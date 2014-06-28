class CreateDownloadSoftwares < ActiveRecord::Migration
  def change
    create_table :download_softwares do |t|
      t.string :name
      t.string :description
      t.string :file
      t.string :file_file_name
      t.string :file_content_type
      t.integer :file_file_size
      t.datetime :file_update_at

      t.timestamps
    end
  end
end
