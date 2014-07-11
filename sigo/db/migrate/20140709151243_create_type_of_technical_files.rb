class CreateTypeOfTechnicalFiles < ActiveRecord::Migration
  def change
  	if !table_exists? :type_of_technical_files
	    create_table :type_of_technical_files do |t|
	      t.string :name
	      t.string :preffix
	      t.integer :cost_center_id

	      t.timestamps
	    end
	  end
  end
end
