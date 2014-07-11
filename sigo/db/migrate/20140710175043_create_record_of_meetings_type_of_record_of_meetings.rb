class CreateRecordOfMeetingsTypeOfRecordOfMeetings < ActiveRecord::Migration
  def change
    create_table :record_of_meetings_type_of_record_of_meetings do |t|
      t.integer :record_of_meeting_id
      t.integer :type_of_record_of_meeting_id

      t.timestamps
    end
  end
end
