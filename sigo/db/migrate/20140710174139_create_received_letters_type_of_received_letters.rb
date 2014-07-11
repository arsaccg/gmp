class CreateReceivedLettersTypeOfReceivedLetters < ActiveRecord::Migration
  def change
  	if !table_exists? :received_letters_type_of_received_letters
	    create_table :received_letters_type_of_received_letters do |t|
	      t.integer :received_letter_id
	      t.integer :type_of_received_letter_id

	      t.timestamps
	    end
	  end
  end
end
