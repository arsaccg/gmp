class RemoveAncientTablesFromDatabase < ActiveRecord::Migration
  def change
    drop_table :attachment_arbitration_documents if table_exists? :attachment_arbitration_documents
    drop_table :attachment_contract_documents if table_exists? :attachment_contract_documents
    drop_table :attachment_integrated_bases_documents if table_exists? :attachment_integrated_bases_documents
    drop_table :attachment_testimony_of_consortium_documents if table_exists? :attachment_testimony_of_consortium_documents
  end
end
