class AddCompanyIdToCostCenter < ActiveRecord::Migration
  def change
    add_column :cost_centers, :company_id, :integer
  end
end
