class ChangeNameColumnInPayslip < ActiveRecord::Migration
  def change
  	change_column :payslips, :start_date, :string
  	rename_column :payslips, :start_date, :week
  	remove_column :payslips, :end_date
  end
end
