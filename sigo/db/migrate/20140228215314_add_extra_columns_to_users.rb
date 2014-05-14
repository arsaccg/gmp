class AddExtraColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :surname, :string
    add_column :users, :date_of_birth, :date
    add_column :users, :avatar, :string
  end
end
