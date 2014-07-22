class AddIgvToProvisions < ActiveRecord::Migration
  def change
  	add_column :provision_details,:current_igv, :float
  end
end
