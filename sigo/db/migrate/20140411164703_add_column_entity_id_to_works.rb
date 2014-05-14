class AddColumnEntityIdToWorks < ActiveRecord::Migration
  def change
    add_column :works, :entity_id, :integer
  end
end
