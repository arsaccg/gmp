class AddColumnToProvisionDirectExtraCalculation < ActiveRecord::Migration
  def change
    add_column :provision_direct_extra_calculations, :apply, :string
  end
end
