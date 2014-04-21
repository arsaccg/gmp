class CreateAttachmentTestimonyOfConsortiumDocuments < ActiveRecord::Migration
  def change
    create_table :attachment_testimony_of_consortium_documents do |t|
      t.integer :work_id
      t.string :attachment
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_update_at

      t.timestamps
    end
  end
end
