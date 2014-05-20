class RemoveSectorIdFromPartWork < ActiveRecord::Migration
  def change
  	remove_column :part_works, :sector_id
  end
end
