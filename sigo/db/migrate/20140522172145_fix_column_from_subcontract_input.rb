class FixColumnFromSubcontractInput < ActiveRecord::Migration
  def change
  	change_column :subcontract_inputs, :type_article, :string
  end
end
