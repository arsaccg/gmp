class AddSecondNameToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :second_name, :string
  end
end
