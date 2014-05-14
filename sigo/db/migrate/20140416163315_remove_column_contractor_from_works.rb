class RemoveColumnContractorFromWorks < ActiveRecord::Migration
  def change
    remove_column :works, :contractor, :string
  end
end
