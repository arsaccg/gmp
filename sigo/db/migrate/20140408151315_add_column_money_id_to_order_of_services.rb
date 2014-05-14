class AddColumnMoneyIdToOrderOfServices < ActiveRecord::Migration
  def change
    add_column :order_of_services, :money_id, :integer
  end
end
