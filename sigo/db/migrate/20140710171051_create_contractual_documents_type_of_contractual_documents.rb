class CreateContractualDocumentsTypeOfContractualDocuments < ActiveRecord::Migration
  def change
  	if !table_exists? :contractual_documents_type_of_contractual_documents
	    create_table :contractual_documents_type_of_contractual_documents do |t|
	      t.integer :contractual_document_id
	      t.integer :type_of_contractual_document_id

	      t.timestamps
	    end
	  end
  end
end
