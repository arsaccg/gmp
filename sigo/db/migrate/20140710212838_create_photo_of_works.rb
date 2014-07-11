class CreatePhotoOfWorks < ActiveRecord::Migration
  def change
    create_table :photo_of_works do |t|
      t.string :name
      t.string :description
      t.integer :cost_center_id
      t.string :photo
      t.string :photo_file_name
      t.string :photo_content_type
      t.integer :photo_file_size
      t.datetime :photo_updated_at

      t.timestamps
    end
  end
end
