class AddIgvToCostCenter < ActiveRecord::Migration
  def change
    add_column :cost_centers, :igv, :bit
  end
end
