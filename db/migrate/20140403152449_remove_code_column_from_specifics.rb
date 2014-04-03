class RemoveCodeColumnFromSpecifics < ActiveRecord::Migration
  def change
  	remove_column :specifics, :code, :integer
  end
end
