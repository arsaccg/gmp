class AddColumnsOfHistoricToOrderOfServices < ActiveRecord::Migration
  def change
    add_column :order_of_services, :user_id_historic, :integer
    add_column :order_of_services, :date_of_elimination, :date
    add_column :order_of_services, :status, :boolean, :null => false, :default => 1
  end
end
