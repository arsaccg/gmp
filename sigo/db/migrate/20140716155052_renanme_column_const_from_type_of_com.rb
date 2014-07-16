class RenanmeColumnConstFromTypeOfCom < ActiveRecord::Migration
  def change
  	rename_column :type_of_companies, :cost_center_id, :company_id
  end
end
