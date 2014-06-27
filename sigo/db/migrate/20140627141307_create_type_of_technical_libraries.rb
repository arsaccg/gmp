class CreateTypeOfTechnicalLibraries < ActiveRecord::Migration
  def change
    create_table :type_of_technical_libraries do |t|
      t.string :name
      t.string :preffix

      t.timestamps
    end
  end
end
