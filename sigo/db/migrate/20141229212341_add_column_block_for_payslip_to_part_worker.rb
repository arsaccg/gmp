class AddColumnBlockForPayslipToPartWorker < ActiveRecord::Migration
  def change
    add_column :part_workers, :blockpayslip, :boolean, :null => false, :default => 0
  end
end
