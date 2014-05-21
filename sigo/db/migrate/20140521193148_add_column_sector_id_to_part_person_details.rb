class AddColumnSectorIdToPartPersonDetails < ActiveRecord::Migration
  def change
    add_column :part_person_details, :sector_id, :integer
  end
end
