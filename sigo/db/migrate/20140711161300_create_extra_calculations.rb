class CreateExtraCalculations < ActiveRecord::Migration
  def change
  	if !table_exists? :extra_calculations
	    create_table :extra_calculations do |t|
	      t.string :concept
	      t.string :type

	      t.timestamps
	    end
	  end
  end
end
