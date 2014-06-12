class CreateDistributions < ActiveRecord::Migration
  def change
    create_table :distributions do |t|
      t.string :code
      t.string :description
      t.string :und
      t.float :measured

      t.timestamps
    end
  end
end
