class AddOwneritemToItembybudgets < ActiveRecord::Migration
  def change
    add_column :itembybudgets, :owneritem, :string
  end
end
