class Fixitembybugets < ActiveRecord::Migration
  def change
  	rename_column :subcontract_details, :itembybudgets_id, :itembybudget_id
  end
end
