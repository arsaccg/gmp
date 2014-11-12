class AddColumnPayrollUsedToPartPeople < ActiveRecord::Migration
  def change
    add_column :part_people, :payroll_used, :integer, :null => false, :default => 0
    add_column :part_workers, :payroll_used, :integer, :null => false, :default => 0
  end
end
