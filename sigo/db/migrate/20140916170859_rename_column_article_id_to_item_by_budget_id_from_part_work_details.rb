class RenameColumnArticleIdToItemByBudgetIdFromPartWorkDetails < ActiveRecord::Migration
  def change
  	rename_column :part_work_details, :article_id, :itembybudget_id
  end
end
