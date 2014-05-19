class AddDeletedToProject < ActiveRecord::Migration
  def change
    add_column :projects, :deleted, :integer, :default => "0"
  end
end
