class DropAddressFromEntities < ActiveRecord::Migration
  def change
  	remove_column :workers, :dni
  end
end