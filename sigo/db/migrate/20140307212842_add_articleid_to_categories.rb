class AddArticleidToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :article_id, :integer
  end
end
