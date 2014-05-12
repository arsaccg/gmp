class RemoveColumnEntityIdFromCertificates < ActiveRecord::Migration
  def change
  	remove_column :certificates, :entity_id, :integer
  end
end
