class CreateExtraCalculations < ActiveRecord::Migration
  def change
    create_table :extra_calculations do |t|
      t.string :concept
      t.string :type

      t.timestamps
    end
  end
end
