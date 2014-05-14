class AddColumnCodeToPhases < ActiveRecord::Migration
  def change
    add_column :phases, :code, :string
  end
end
