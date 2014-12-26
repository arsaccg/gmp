class AddColumnTypeConvertedOperationToTypeOfPayslips < ActiveRecord::Migration
  def change
    add_column :type_of_payslips, :type_converted_operation, :string
  end
end
