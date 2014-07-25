class CreateTypeWorkdays < ActiveRecord::Migration
  def change
    create_table :type_workdays do |t|
      t.string :name

      t.timestamps
    end
  end
end
