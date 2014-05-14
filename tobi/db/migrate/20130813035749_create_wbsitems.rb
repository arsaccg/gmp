class CreateWbsitems < ActiveRecord::Migration
  def change
    create_table :wbsitems do |t|
      t.string :codewbs
      t.string :name
      t.string :description
      t.string :notes
      t.timestamps
    end
  end
end
