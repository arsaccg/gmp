class AddColumnNameAndCategoryIdToCategoryOfWorkers < ActiveRecord::Migration
  def change
    add_column :category_of_workers, :name, :string
    add_column :category_of_workers, :category_id, :integer
  end
end
