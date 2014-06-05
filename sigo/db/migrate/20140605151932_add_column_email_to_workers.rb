class AddColumnEmailToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :email, :string
  end
end
