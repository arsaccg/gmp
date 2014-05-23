class RemoveAncientTablesFromDatabase < ActiveRecord::Migration
  def change
  	if AttachmentArbitrationDocuments.table_exists?
      drop_table :attachment_arbitration_documents
  	end
  	if AttachmentContractDocuments.table_exists?
      drop_table :attachment_contract_documents
  	end
  	if AttachmentIntegratedBases_documents.table_exists?
    drop_table :attachment_integrated_bases_documents
	end
	if AttachmentTestimonyOfConsortiumDocuments.table_exists?
      drop_table :attachment_testimony_of_consortium_documents
    end
  end
end
