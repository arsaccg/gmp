class AddGeneralExpensesToValorization < ActiveRecord::Migration
  def change
    add_column :valorizations, :general_expenses, :float
  end
end
