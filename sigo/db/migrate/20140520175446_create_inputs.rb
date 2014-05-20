class CreateInputs < ActiveRecord::Migration
  def change
    create_table :inputs do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
  end
end
