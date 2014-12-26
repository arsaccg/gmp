class AddColumnTypeOfWorkerIdToTypeOfPayslips < ActiveRecord::Migration
  def change
    add_column :type_of_payslips, :type_of_worker_id, :integer
  end
end
