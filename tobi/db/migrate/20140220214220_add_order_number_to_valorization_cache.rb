class AddOrderNumberToValorizationCache < ActiveRecord::Migration
  def change
    add_column :valorization_caches, :order_number, :integer
  end
end
