class AddColumnShortNameToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :short_name, :string
  end
end
