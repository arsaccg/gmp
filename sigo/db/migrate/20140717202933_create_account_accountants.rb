class CreateAccountAccountants < ActiveRecord::Migration
  def change
    create_table :account_accountants do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
  end
end
