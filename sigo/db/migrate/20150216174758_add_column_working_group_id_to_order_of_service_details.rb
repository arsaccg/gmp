class AddColumnWorkingGroupIdToOrderOfServiceDetails < ActiveRecord::Migration
  def change
    add_column :order_of_service_details, :working_group_id, :integer
  end
end
