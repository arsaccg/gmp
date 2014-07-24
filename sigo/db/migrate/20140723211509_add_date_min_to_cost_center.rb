class AddDateMinToCostCenter < ActiveRecord::Migration
  def change
    add_column :cost_centers, :date_min, :date
  end
end
