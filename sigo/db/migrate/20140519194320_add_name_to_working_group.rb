class AddNameToWorkingGroup < ActiveRecord::Migration
  def change
    add_column :working_groups, :name, :string
  end
end
