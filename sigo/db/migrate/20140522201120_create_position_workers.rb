class CreatePositionWorkers < ActiveRecord::Migration
  def change
    create_table :position_workers do |t|
      t.string :name

      t.timestamps
    end
  end
end
