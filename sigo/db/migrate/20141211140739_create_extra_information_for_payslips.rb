class CreateExtraInformationForPayslips < ActiveRecord::Migration
  def change
    create_table :extra_information_for_payslips do |t|
      t.integer :worker_id
      t.integer :concept_id
      t.float :amount
      t.string :week

      t.timestamps
    end
  end
end
