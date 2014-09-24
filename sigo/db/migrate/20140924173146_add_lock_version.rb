class AddLockVersion < ActiveRecord::Migration
  def change
  	add_column :stock_inputs, :lock_version, :integer, :default => 0, :null => false
  	add_column :stock_input_details, :lock_version, :integer, :default => 0, :null => false
  	add_column :purchase_orders, :lock_version, :integer, :default => 0, :null => false
  	add_column :purchase_order_details, :lock_version, :integer, :default => 0, :null => false
  	add_column :purchase_order_extra_calculations, :lock_version, :integer, :default => 0, :null => false
  	add_column :provisions, :lock_version, :integer, :default => 0, :null => false
  	add_column :provision_details, :lock_version, :integer, :default => 0, :null => false
  	add_column :provision_direct_purchase_details, :lock_version, :integer, :default => 0, :null => false
  	add_column :order_of_services, :lock_version, :integer, :default => 0, :null => false
  	add_column :order_of_service_details, :lock_version, :integer, :default => 0, :null => false
  	add_column :order_service_extra_calculations, :lock_version, :integer, :default => 0, :null => false
  	add_column :subcontracts, :lock_version, :integer, :default => 0, :null => false
  	add_column :subcontract_advances, :lock_version, :integer, :default => 0, :null => false
  	add_column :subcontract_details, :lock_version, :integer, :default => 0, :null => false
  	add_column :subcontract_equipments, :lock_version, :integer, :default => 0, :null => false
  	add_column :subcontract_equipment_advances, :lock_version, :integer, :default => 0, :null => false
  	add_column :subcontract_equipment_details, :lock_version, :integer, :default => 0, :null => false
  	add_column :workers, :lock_version, :integer, :default => 0, :null => false
  	add_column :worker_center_of_studies, :lock_version, :integer, :default => 0, :null => false
  	add_column :worker_contracts, :lock_version, :integer, :default => 0, :null => false
  	add_column :worker_details, :lock_version, :integer, :default => 0, :null => false
  	add_column :worker_experiences, :lock_version, :integer, :default => 0, :null => false
  	add_column :worker_familiars, :lock_version, :integer, :default => 0, :null => false
  	add_column :worker_healths, :lock_version, :integer, :default => 0, :null => false
  	add_column :worker_otherstudies, :lock_version, :integer, :default => 0, :null => false
  end
end
