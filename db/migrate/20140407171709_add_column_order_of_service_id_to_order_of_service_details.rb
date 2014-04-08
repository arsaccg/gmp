class AddColumnOrderOfServiceIdToOrderOfServiceDetails < ActiveRecord::Migration
  def change
    add_column :order_of_service_details, :order_of_service_id, :integer
  end
end
