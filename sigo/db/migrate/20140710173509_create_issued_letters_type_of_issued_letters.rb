class CreateIssuedLettersTypeOfIssuedLetters < ActiveRecord::Migration
  def change
    create_table :issued_letters_type_of_issued_letters do |t|
      t.integer :issued_letter_id
      t.integer :type_of_issued_letter_id

      t.timestamps
    end
  end
end
