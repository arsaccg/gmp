class CreateWorkers < ActiveRecord::Migration
  def change
    create_table :workers do |t|
      t.string :first_name
      t.string :paternal_surname
      t.string :maternal_surname
      t.string :email
      t.string :phone
      t.string :bank
      t.string :account_number
      t.date :date_of_birth
      t.text :address

      t.timestamps
    end
  end
end
