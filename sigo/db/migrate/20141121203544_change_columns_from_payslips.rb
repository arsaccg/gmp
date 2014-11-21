class ChangeColumnsFromPayslips < ActiveRecord::Migration
  def change
    rename_column :payslips, :initial_day, :start_date
    rename_column :payslips, :final_day, :end_date
    rename_column :payslips, :worked_day, :days
    rename_column :payslips, :worked_hour, :normal_hours
    rename_column :payslips, :fail_hour, :he_60
    rename_column :payslips, :total_income, :he_100
    change_column :payslips, :fail_day, :date
    rename_column :payslips, :fail_day, :last_worked_day
    change_column :payslips, :net_payment, :string
    rename_column :payslips, :net_payment, :code
    change_column :payslips, :status, :string
    rename_column :payslips, :status, :month
    remove_column :payslips, :total_discount, :float
    change_column :payslips, :total_contributions, :text, :limit => 4294967295
    rename_column :payslips, :total_contributions, :concepts_and_amounts


  end
end