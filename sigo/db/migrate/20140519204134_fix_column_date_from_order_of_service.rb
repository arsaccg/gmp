class FixColumnDateFromOrderOfService < ActiveRecord::Migration
  def change
  	change_column :order_of_services, :date_of_service, :date
  	change_column :order_of_services, :date_of_issue, :date
  end
end
