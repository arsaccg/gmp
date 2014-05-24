class RemoveSpecificFromDatabase < ActiveRecord::Migration
  def change
  	drop_table :specifics if table_exists? :specifics
    drop_table :subcategories if table_exists? :subcategories
  end
end
