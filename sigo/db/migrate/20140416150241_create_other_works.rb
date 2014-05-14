class CreateOtherWorks < ActiveRecord::Migration
  def change
    create_table :other_works do |t|
      t.string :name
      t.date :start
      t.date :end
      t.integer :components

      t.timestamps
    end
  end
end
