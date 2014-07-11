class CreateContestDocumentsTypeOfContestDocuments < ActiveRecord::Migration
  def change
    create_table :contest_documents_type_of_contest_documents do |t|
      t.integer :contest_document_id
      t.integer :type_of_contest_document_id

      t.timestamps
    end
  end
end
