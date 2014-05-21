class RemoveSectorIdFromPartPersonDetail < ActiveRecord::Migration
  def change
  	remove_column :part_person_details, :sector_id
  end
end
