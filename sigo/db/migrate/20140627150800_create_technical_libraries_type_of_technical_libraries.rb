class CreateTechnicalLibrariesTypeOfTechnicalLibraries < ActiveRecord::Migration
  def change
    create_table :technical_libraries_type_of_technical_libraries do |t|
      t.integer :technical_library_id
      t.integer :type_of_technical_library_id

      t.timestamps
    end
  end
end
