class CreateSubDailies < ActiveRecord::Migration
  def change
    create_table :sub_dailies do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
  end
end
