class CreateBookWorksTypeOfBookWorks < ActiveRecord::Migration
  def change
  	if !table_exists? :book_works_type_of_book_works
	    create_table :book_works_type_of_book_works do |t|
	      t.integer :book_work_id
	      t.integer :type_of_book_work_id

	      t.timestamps
	    end
	  end
  end
end