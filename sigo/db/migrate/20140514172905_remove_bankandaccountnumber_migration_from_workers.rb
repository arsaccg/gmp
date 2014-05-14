class RemoveBankandaccountnumberMigrationFromWorkers < ActiveRecord::Migration
  def change
    remove_column :workers, :bank, :string
    remove_column :workers, :account_number, :string
  end
end
