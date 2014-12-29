class AddColumnBlockweeklyToPartWorker < ActiveRecord::Migration
  def change
    add_column :part_workers, :blockweekly, :boolean, :null => false, :default => 0
  end
end
