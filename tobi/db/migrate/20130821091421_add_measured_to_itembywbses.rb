class AddMeasuredToItembywbses < ActiveRecord::Migration
  def change
    add_column :itembywbses, :measured, :float,  { :length => 10, :decimals => 2 }
  end
end
