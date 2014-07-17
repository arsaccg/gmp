class CreateConcepts < ActiveRecord::Migration
  def change
    create_table :concepts do |t|
      t.string :name
      t.float :percentage
      t.float :amount
      t.string :code
      t.float :top

      t.timestamps
    end
  end
end
