class CreateComponets < ActiveRecord::Migration
  def change
    create_table :componets do |t|
      t.string :type

      t.timestamps
    end
  end
end
