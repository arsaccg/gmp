class Inputcategories < ActiveRecord::Migration
  def change
  	create_table :inputcategories do |t|
      t.integer :category_id
      t.integer :level_n
      t.string :description

      t.timestamps
    end
  end
end
