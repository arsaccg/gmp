class AddColumnTypeOfPayslipIdToPayslips < ActiveRecord::Migration
  def change
    add_column :payslips, :type_of_payslip_id, :integer
  end
end
