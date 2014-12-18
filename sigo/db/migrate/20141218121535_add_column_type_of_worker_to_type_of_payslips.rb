class AddColumnTypeOfWorkerToTypeOfPayslips < ActiveRecord::Migration
  def change
    add_column :type_of_payslips, :type_of_worker, :string
  end
end
