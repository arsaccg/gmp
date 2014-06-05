class AddColumnSecondNameToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :second_name, :string
  end
end
