class AddColumnCodeArticleUnitToArticleUnitOfMeasurements < ActiveRecord::Migration
  def change
    add_column :article_unit_of_measurements, :code_article_unit, :string
  end
end
