class AddUtilityToValorization < ActiveRecord::Migration
  def change
    add_column :valorizations, :utility, :float
  end
end
