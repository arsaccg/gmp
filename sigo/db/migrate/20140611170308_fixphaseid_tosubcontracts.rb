class FixphaseidTosubcontracts < ActiveRecord::Migration
  def change
  	remove_column :subcontract_details, :phase_id
  	add_column :subcontract_details, :itembybudgets_id, :integer
  end
end
