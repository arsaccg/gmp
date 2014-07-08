class AddColumnCodeToPhases < ActiveRecord::Migration
  def change
  	unless column_exists? :phases, :code
      add_column :phases, :code, :string
    end
  end
end
