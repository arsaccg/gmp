class CreateWorkerRentFifthCategories < ActiveRecord::Migration
  def change
    create_table :worker_rent_fifth_categories do |t|
      t.integer :worker_id
      t.float :previous_salary
      t.float :rent
      t.date :date_last_rent

      t.timestamps
    end
  end
end
