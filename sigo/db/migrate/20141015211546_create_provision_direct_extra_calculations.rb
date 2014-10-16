class CreateProvisionDirectExtraCalculations < ActiveRecord::Migration
  def change
    create_table :provision_direct_extra_calculations do |t|
      t.integer :provision_direct_purchase_detail_id
      t.integer :extra_calculation_id
      t.float :value
      t.string :operation
      t.string :type
      t.integer :lock_version

      t.timestamps
    end
  end
end
