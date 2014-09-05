class AddColumnNumberRegToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :number_position, :string
  end
end
