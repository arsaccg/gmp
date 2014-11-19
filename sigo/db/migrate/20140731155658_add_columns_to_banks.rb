class AddColumnsToBanks < ActiveRecord::Migration
  def change
    add_column :banks, :money_id, :integer
    add_column :banks, :account_type, :string
    add_column :banks, :account_number, :string
    add_column :banks, :account_detraction, :string
    add_column :banks, :cci, :string
  end
end
