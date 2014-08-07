class AddColumnFolderIdToPhotoOfWork < ActiveRecord::Migration
  def change
    add_column :photo_of_works, :folder_id, :integer
  end
end
