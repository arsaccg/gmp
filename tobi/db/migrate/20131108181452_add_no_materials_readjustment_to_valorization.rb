class AddNoMaterialsReadjustmentToValorization < ActiveRecord::Migration
  def change
    add_column :valorizations, :no_materials_r, :float
  end
end
