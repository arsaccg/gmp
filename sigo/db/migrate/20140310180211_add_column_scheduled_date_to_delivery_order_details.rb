class AddColumnScheduledDateToDeliveryOrderDetails < ActiveRecord::Migration
  def change
    add_column :delivery_order_details, :scheduled_date, :date
  end
end
