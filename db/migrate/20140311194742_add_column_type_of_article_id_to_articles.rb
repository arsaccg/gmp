class AddColumnTypeOfArticleIdToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :type_of_article_id, :integer
  end
end
