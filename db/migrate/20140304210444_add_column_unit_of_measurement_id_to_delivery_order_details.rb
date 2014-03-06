class AddColumnUnitOfMeasurementIdToDeliveryOrderDetails < ActiveRecord::Migration
  def change
    add_column :delivery_order_details, :unit_of_measurement_id, :integer
  end
end
