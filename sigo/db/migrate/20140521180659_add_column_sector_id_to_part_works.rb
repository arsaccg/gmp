class AddColumnSectorIdToPartWorks < ActiveRecord::Migration
  def change
    add_column :part_works, :sector_id, :integer
  end
end
