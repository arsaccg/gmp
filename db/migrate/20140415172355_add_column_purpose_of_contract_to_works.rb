class AddColumnPurposeOfContractToWorks < ActiveRecord::Migration
  def change
    add_column :works, :purpose_of_contract, :string
  end
end
