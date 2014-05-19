class AddAdvanceOfMaterialsToValorization < ActiveRecord::Migration
  def change
    add_column :valorizations, :advance_of_materials, :float
  end
end
