class AddMoreColumnsToAfp < ActiveRecord::Migration
  def change
    add_column :afps, :contribution_fp, :float
    add_column :afps, :insurance_premium, :float
    add_column :afps, :top, :float
    add_column :afps, :c_variable, :float
    rename_column :afps, :percentage, :mixed
  end
end
