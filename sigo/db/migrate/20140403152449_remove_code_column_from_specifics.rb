class RemoveCodeColumnFromSpecifics < ActiveRecord::Migration
  def change
  	remove_column :specifics, :code, :integer if table_exists? :specifics
  end
end
