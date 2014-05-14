class RemoveColumnDescriptionFromArticles < ActiveRecord::Migration
  def change
  	remove_column :articles, :description
  end
end
