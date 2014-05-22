class AddArticleIdAndRemoveCategoryWorkerIdToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :article_id, :integer
    remove_column :workers, :category_of_worker_id
  end
end
