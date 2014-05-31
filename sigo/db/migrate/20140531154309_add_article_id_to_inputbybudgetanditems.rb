class AddArticleIdToInputbybudgetanditems < ActiveRecord::Migration
  def change
    add_column :inputbybudgetanditems, :article_id, :integer
  end
end
