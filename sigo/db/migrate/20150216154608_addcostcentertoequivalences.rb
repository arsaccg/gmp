class Addcostcentertoequivalences < ActiveRecord::Migration
  def change
    add_column :equivalence_of_items, :cost_center_id, :integer
  end
end
