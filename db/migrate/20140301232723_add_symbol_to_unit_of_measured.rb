class AddSymbolToUnitOfMeasured < ActiveRecord::Migration
  def change
    add_column :unit_of_measurements, :symbol, :string
  end
end
