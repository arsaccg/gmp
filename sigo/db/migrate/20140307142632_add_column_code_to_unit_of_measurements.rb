class AddColumnCodeToUnitOfMeasurements < ActiveRecord::Migration
  def change
    add_column :unit_of_measurements, :code, :string
  end
end
