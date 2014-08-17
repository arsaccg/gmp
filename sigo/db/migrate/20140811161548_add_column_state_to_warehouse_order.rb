class AddColumnStateToWarehouseOrder < ActiveRecord::Migration
  def change
    add_column :warehouse_orders, :state, :string
    add_column :warehouse_orders, :user_id, :integer
  end
end

