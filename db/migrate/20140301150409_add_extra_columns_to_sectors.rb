class AddExtraColumnsToSectors < ActiveRecord::Migration
  def change
    add_column :sectors, :code, :string
  end
end
