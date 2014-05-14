class AddColumnNumberOfSettlementToWorks < ActiveRecord::Migration
  def change
    add_column :works, :number_of_settlement, :string
  end
end
