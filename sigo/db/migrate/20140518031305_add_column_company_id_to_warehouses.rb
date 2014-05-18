class AddColumnCompanyIdToWarehouses < ActiveRecord::Migration
  def change
    add_reference :warehouses, :company, index: true
  end
end
