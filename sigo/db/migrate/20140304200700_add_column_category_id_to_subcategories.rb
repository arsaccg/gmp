class AddColumnCategoryIdToSubcategories < ActiveRecord::Migration
  def change
    add_column :subcategories, :category_id, :integer if table_exists? :subcategories
  end
end
