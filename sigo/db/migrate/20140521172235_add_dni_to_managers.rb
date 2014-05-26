class AddDniToManagers < ActiveRecord::Migration
  def change
    add_column :managers, :dni, :integer
  end
end
