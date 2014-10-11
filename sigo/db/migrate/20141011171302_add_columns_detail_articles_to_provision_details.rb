class AddColumnsDetailArticlesToProvisionDetails < ActiveRecord::Migration
  def change
    add_column :provision_details, :article_code, :string
    add_column :provision_details, :article_name, :string
    add_column :provision_details, :unit_of_measurement, :string
  end
end
