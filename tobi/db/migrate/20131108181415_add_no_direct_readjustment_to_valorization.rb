class AddNoDirectReadjustmentToValorization < ActiveRecord::Migration
  def change
    add_column :valorizations, :no_direct_r, :float
  end
end
