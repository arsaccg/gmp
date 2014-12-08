class AddColumnSpecialityToCostCenters < ActiveRecord::Migration
  def change
    add_column :cost_centers, :speciality, :string
  end
end
