class CreateContestDocuments < ActiveRecord::Migration
  def change
    if !table_exists? :contest_documents
      create_table :contest_documents do |t|
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
end
