class CreateSubcontractAdvances < ActiveRecord::Migration
  def change
    create_table :subcontract_advances do |t|
      t.date :date_of_issue
      t.float :advance
      t.integer :subcontract_id

      t.timestamps
    end
  end
end
