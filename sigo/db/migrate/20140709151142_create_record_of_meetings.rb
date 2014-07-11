class CreateRecordOfMeetings < ActiveRecord::Migration
  def change
    create_table :record_of_meetings do |t|
      t.string :name
      t.string :description
      t.integer :cost_center_id
      t.string :document
      t.string :document_file_name
      t.string :document_content_type
      t.integer :document_file_size
      t.datetime :document_updated_at

      t.timestamps
    end
  end
end
