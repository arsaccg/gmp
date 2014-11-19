class AddColumnDateToBookWorks < ActiveRecord::Migration
  def change
    add_column :book_works, :date, :date
  end
end
