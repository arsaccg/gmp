class AddColumnDniToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :dni, :string
  end
end
