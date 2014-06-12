class RenameBlock2FromTables < ActiveRecord::Migration
  def change
  	rename_column :part_people, :block2, :blockweekly
  end
end
