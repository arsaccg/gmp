class AddcostCenterIdToscValuations < ActiveRecord::Migration
  def change
  	add_column :sc_valuations, :cost_center_id, :integer
  end
end
