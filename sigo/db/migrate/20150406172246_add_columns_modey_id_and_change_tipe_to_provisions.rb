class AddColumnsModeyIdAndChangeTipeToProvisions < ActiveRecord::Migration
  def change
    add_column :provisions, :money_id, :integer
    add_column :provisions, :exchange_of_rate, :float
  end
end
