class AddColumnCodeToSpecifics < ActiveRecord::Migration
  def change
  	add_column :specifics, :code, :string if table_exists? :specifics
  end
end
