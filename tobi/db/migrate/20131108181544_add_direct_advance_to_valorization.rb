class AddDirectAdvanceToValorization < ActiveRecord::Migration
  def change
    add_column :valorizations, :direct_advance, :float
  end
end
