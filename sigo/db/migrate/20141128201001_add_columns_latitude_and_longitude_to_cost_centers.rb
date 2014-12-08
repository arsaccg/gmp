class AddColumnsLatitudeAndLongitudeToCostCenters < ActiveRecord::Migration
  def change
    add_column :cost_centers, :latitude, :string
    add_column :cost_centers, :longitude, :string
  end
end
