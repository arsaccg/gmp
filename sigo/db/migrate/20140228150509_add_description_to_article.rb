class AddDescriptionToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :description, :integer
  end
end
