class AddColumncodeToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :code, :string
  end
end
