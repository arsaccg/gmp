class AddColumnsToOtherWorks < ActiveRecord::Migration
  def change
    add_column :other_works, :entity, :string
    add_column :other_works, :contractor, :string
  end
end
