class AddColumnCompanyIdToPayslips < ActiveRecord::Migration
  def change
    add_column :payslips, :company_id, :integer
  end
end
