class AddColumnDateOfServiceToOrderOfServices < ActiveRecord::Migration
  def change
    add_column :order_of_services, :date_of_service, :datetime
  end
end
