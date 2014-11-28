class AddColumnsHashToPayslips < ActiveRecord::Migration
  def change
    rename_column :payslips, :concepts_and_amounts, :ing_and_amounts
  	add_column :payslips, :des_and_amounts, :text, :limit => 4294967295
  	add_column :payslips, :aport_and_amounts, :text, :limit => 4294967295
  end
end
