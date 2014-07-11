class CreateTechnicalFilesTypeOfTechnicalFiles < ActiveRecord::Migration
  def change
    create_table :technical_files_type_of_technical_files do |t|
      t.integer :technical_file_id
      t.integer :type_of_technical_file_id

      t.timestamps
    end
  end
end
