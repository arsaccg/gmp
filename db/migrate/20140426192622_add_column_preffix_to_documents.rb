class AddColumnPreffixToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :preffix, :string
  end
end
