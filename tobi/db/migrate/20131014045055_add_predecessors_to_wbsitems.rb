class AddPredecessorsToWbsitems < ActiveRecord::Migration
  def change
    add_column :wbsitems, :predecessors, :string
  end
end
