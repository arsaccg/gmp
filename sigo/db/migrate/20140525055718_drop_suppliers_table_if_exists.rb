class DropSuppliersTableIfExists < ActiveRecord::Migration
  def change
    drop_table :suppliers if table_exists? :suppliers
  end
end
