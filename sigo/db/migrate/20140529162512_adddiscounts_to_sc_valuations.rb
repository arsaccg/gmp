class AdddiscountsToScValuations < ActiveRecord::Migration
  def change
  	add_column :sc_valuations, :otherdiscount, :float
  	add_column :sc_valuations, :accumulated_otherdiscount, :float
  end
end
