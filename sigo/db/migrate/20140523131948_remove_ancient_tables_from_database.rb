class RemoveAncientTablesFromDatabase < ActiveRecord::Migration
  def change
    drop_table :attachment_arbitration_documents
    drop_table :attachment_contract_documents
    drop_table :attachment_integrated_bases_documents
    drop_table :attachment_testimony_of_consortium_documents
  end
end
