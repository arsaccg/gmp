class CreateTypeOfArticles < ActiveRecord::Migration
  def change
    create_table :type_of_articles do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
  end
end
