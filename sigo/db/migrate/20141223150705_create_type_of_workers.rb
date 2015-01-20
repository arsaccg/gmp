class CreateTypeOfWorkers < ActiveRecord::Migration
  def change
    create_table :type_of_workers do |t|
      t.string :name
      t.text :description
      t.string :prefix
      t.string :worker_type

      t.timestamps
    end
  end
end
