class CreateTypeWorkdays < ActiveRecord::Migration
  def change
  	if !table_exists? :type_workdays
	    create_table :type_workdays do |t|
	      t.string :name

	      t.timestamps
	    end
	  end
  end
end
