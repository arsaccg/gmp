class AddColumnCostCenterToTypeOfPayslip < ActiveRecord::Migration
  def change
    add_column :type_of_payslips, :cost_center_id, :integer
  end
end
