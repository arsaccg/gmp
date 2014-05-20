class AddIgvToProject < ActiveRecord::Migration
  def change
    add_column :projects, :igv, :float
  end
end
