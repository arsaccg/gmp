class CreateGeneralExpenses < ActiveRecord::Migration
  def change
  	if !table_exists? :general_expenses
	    create_table :general_expenses do |t|
	      t.integer :phase_id
	      t.integer :cost_center_id

	      t.timestamps
	    end
	  end
  end
end
