class AddColumnDateToIssuedLetters < ActiveRecord::Migration
  def change
    add_column :issued_letters, :date, :date
    add_column :received_letters, :date, :date
  end
end
