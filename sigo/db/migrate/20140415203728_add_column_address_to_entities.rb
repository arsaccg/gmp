class AddColumnAddressToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :address, :text
  end
end
