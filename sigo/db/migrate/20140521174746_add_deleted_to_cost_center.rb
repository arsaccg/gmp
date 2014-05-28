class AddDeletedToCostCenter < ActiveRecord::Migration
  def change
    add_column :cost_centers, :deleted, :integer, :default => 0
  end
end
