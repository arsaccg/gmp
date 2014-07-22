class AddcurrentpriceToProvisions < ActiveRecord::Migration
  def change
  	add_column :provision_details,:current_unit_price, :float
  end
end
