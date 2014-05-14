class AddColumnRucAndAddressToWorkPartners < ActiveRecord::Migration
  def change
    add_column :work_partners, :ruc, :string
    add_column :work_partners, :address, :text
  end
end
