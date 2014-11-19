class CreateLoans < ActiveRecord::Migration
  def change
    create_table :loans do |t|
      t.integer :entity_id
      t.string :beneficiary
      t.date :loan_date
      t.string :loan_type
      t.float :amount
      t.string :description
      t.string :refund_type
      t.string :check_number
      t.date :check_date
      t.string :state
      t.date :refund_date

      t.timestamps
    end
  end
end
