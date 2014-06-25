class RenameColumnComponentsIdFromCertificates < ActiveRecord::Migration
  def change
  	rename_column :certificates, :componetns_id, :other_work_id
  end
end
