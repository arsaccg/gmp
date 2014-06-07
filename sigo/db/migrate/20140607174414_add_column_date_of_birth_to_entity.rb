class AddColumnDateOfBirthToEntity < ActiveRecord::Migration
  def change
  	add_column :entities, :date_of_birth, :date
  end
end
