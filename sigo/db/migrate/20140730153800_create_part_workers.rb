class CreatePartWorkers < ActiveRecord::Migration
  def change
    create_table :part_workers do |t|
    	t.string :number_part
      t.date :date_of_creation
      t.integer :company_id

      t.timestamps
    end
  end
end
