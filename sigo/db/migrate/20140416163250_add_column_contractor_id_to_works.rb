class AddColumnContractorIdToWorks < ActiveRecord::Migration
  def change
    add_column :works, :contractor_id, :integer
  end
end
