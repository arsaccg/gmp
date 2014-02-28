class DropTableUnitOfMeasuresTable < ActiveRecord::Migration
  def change
  	drop_table :unit_of_measures
  end
end
