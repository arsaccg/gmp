class CreateTypeOfReceivedLetters < ActiveRecord::Migration
  def change
    create_table :type_of_received_letters do |t|
      t.string :name
      t.string :preffix
      t.integer :cost_center_id

      t.timestamps
    end
  end
end
