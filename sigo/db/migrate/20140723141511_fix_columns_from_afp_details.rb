class FixColumnsFromAfpDetails < ActiveRecord::Migration
  def change
  	add_column :afp_details, :contribution_fp, :float
    add_column :afp_details, :insurance_premium, :float
    add_column :afp_details, :top, :float
    add_column :afp_details, :c_variable, :float
    rename_column :afp_details, :percentage, :mixed
  end
end
