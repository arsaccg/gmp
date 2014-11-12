class CreatePayrollDetails < ActiveRecord::Migration
  def change
  	if !table_exists? :payroll_details
      create_table :payroll_details do |t|
        t.integer :payroll_id
        t.integer :concept_id
        t.float :amount
        t.string :type_con

        t.timestamps
      end
    end
  end
end
