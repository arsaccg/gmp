class AddColumnTypeToSubcontracts < ActiveRecord::Migration
  def change
    add_column :subcontracts, :type, :string
  end
end
