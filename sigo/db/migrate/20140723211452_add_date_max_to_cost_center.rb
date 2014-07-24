class AddDateMaxToCostCenter < ActiveRecord::Migration
  def change
    add_column :cost_centers, :date_max, :date
  end
end
