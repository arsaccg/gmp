class CreateMeasuredBySectors < ActiveRecord::Migration
  def change
    if !table_exists? :measured_by_sectors
      create_table :measured_by_sectors do |t|
        t.integer :item_id
        t.integer :sector_id
        t.float :measured

        t.timestamps
      end
    end
  end
end
