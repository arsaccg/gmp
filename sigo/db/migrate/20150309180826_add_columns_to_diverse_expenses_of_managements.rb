class AddColumnsToDiverseExpensesOfManagements < ActiveRecord::Migration
  def change
    add_column :diverse_expenses_of_managements, :article_code, :string, :default => "0576059999"
    add_column :diverse_expenses_of_managements, :phase_id, :integer
  end
end
