class AddColumsDateBeginAndDateFinnihToPayslips < ActiveRecord::Migration
  def change
    add_column :payslips, :date_begin, :date
    add_column :payslips, :date_end, :date
  end
end
