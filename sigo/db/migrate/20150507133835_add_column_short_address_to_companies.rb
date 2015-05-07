class AddColumnShortAddressToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :short_address, :string
  end
end
