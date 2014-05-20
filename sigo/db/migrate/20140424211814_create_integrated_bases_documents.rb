class CreateIntegratedBasesDocuments < ActiveRecord::Migration
  def change
    create_table :integrated_bases_documents do |t|
      t.string :attachment
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.string :attachment_file_size
      t.datetime :attachment_update_at
      t.integer :work_id

      t.timestamps
    end
  end
end