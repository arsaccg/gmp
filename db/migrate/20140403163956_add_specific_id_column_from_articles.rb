class AddSpecificIdColumnFromArticles < ActiveRecord::Migration
  def change
    add_column :articles, :specific_id, :integer
  end
end
