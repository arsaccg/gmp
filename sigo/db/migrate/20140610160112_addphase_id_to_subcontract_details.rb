class AddphaseIdToSubcontractDetails < ActiveRecord::Migration
  def change
  	add_column :subcontract_details, :phase_id, :string
  end
end
