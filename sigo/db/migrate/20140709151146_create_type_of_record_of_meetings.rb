class CreateTypeOfRecordOfMeetings < ActiveRecord::Migration
  def change
    create_table :type_of_record_of_meetings do |t|
      t.string :name
      t.string :preffix
      t.integer :cost_center_id

      t.timestamps
    end
  end
end
