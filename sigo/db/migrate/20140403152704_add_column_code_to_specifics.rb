class AddColumnCodeToSpecifics < ActiveRecord::Migration
  def change
  	add_column :specifics, :code, :string
  end
end
