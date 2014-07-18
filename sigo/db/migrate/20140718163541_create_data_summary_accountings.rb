class CreateDataSummaryAccountings < ActiveRecord::Migration
  def change
    create_table :data_summary_accountings do |t|
      t.integer :account_accountant_id
      t.integer :sub_daily_id
      t.date :accounting_date
      t.float :amount

      t.timestamps
    end
  end
end
