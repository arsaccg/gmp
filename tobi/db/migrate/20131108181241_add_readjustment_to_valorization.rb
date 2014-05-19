class AddReadjustmentToValorization < ActiveRecord::Migration
  def change
    add_column :valorizations, :readjustment, :float
  end
end
