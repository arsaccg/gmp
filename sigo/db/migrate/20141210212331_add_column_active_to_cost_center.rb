class AddColumnActiveToCostCenter < ActiveRecord::Migration
  def change
    add_column :cost_centers, :active, :boolean
  end
end
