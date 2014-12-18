class AddColumnForWorkerEmployeeToTypeOfPayslips < ActiveRecord::Migration
  def change
    add_column :type_of_payslips, :for_worker_employee, :string
  end
end
