class AddColumnsToSeveralsTables < ActiveRecord::Migration
  def change
  	add_column :download_softwares, :type_of_cost_center, :string
  	add_column :interest_links, :type_of_cost_center, :string
  	add_column :law_and_regulations, :type_of_cost_center, :string
  	add_column :technical_libraries, :type_of_cost_center, :string
  	add_column :technical_standards, :type_of_cost_center, :string
  end
end
