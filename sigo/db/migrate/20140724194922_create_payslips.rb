class CreatePayslips < ActiveRecord::Migration
  def change
    if !table_exists? :payslips
      create_table :payslips do |t|
        t.integer :worker_id
        t.integer :cost_center_id
        t.date :initial_day
        t.date :final_day
        t.integer :worked_day
        t.float :worked_hour
        t.integer :subsidized_day
        t.float :subsidized_hour
        t.integer :fail_day
        t.float :fail_hour
        t.float :net_payment
        t.float :total_income
        t.float :total_discount
        t.float :total_contributions
        t.integer :status

        t.timestamps
      end
    end
  end
end
