class AddKindToManager < ActiveRecord::Migration
  def change
    add_column :managers, :kind, :string
  end
end
