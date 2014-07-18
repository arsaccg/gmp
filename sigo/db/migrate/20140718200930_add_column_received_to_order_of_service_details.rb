class AddColumnReceivedToOrderOfServiceDetails < ActiveRecord::Migration
  def change
    add_column :order_of_service_details, :received, :bool
  end
end
