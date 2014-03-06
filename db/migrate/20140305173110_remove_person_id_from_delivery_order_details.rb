class RemovePersonIdFromDeliveryOrderDetails < ActiveRecord::Migration
  def change
    remove_column :delivery_order_details, :person_id, :integer
  end
end
