class AddColumnTypeArticleToSubcontractInput < ActiveRecord::Migration
  def change
    add_column :subcontract_inputs, :type_article, :integer
  end
end
