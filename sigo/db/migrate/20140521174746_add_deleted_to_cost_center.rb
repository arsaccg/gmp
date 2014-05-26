class AddDeletedToCostCenter < ActiveRecord::Migration
  def change
    add_column :cost_centers, :deleted, :integer
  end
end
