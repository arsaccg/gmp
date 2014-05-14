class FixColumnChargeFromCertificates < ActiveRecord::Migration
  def change
  	rename_column :certificates, :charge, :charge_id
  	change_column :certificates, :charge_id, :integer
  end
end
