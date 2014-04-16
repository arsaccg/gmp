class FixColumnContractorFromCertificate < ActiveRecord::Migration
  def change
  	rename_column :certificates, :contractor, :entity_id
  	change_column :certificates, :entity_id, :integer
  end
end
