class MoveCompanyid < ActiveRecord::Migration
  def change
  	remove_column :part_worker_details, :company_id
  end
end
