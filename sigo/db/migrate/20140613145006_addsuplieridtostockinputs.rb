class Addsuplieridtostockinputs < ActiveRecord::Migration
  def change
  	add_column :stock_inputs, :supplier_id, :integer
  	add_column :stock_inputs, :series, :string
  end
end
