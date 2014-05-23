class AddigvadvanceToSubcontracts < ActiveRecord::Migration
  def change
  	add_column :subcontracts, :igv, :float
  end
end
