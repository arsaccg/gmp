class AddColumnsToTypeOfPayslips < ActiveRecord::Migration
  def change
    add_column :type_of_payslips, :type_of_payslips_id, :integer
    add_column :type_of_payslips, :type_operation, :string
    add_column :type_of_payslips, :name_operation, :string
  end
end
