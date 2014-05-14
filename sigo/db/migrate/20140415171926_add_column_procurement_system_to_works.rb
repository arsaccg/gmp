class AddColumnProcurementSystemToWorks < ActiveRecord::Migration
  def change
    add_column :works, :procurement_system, :string
    add_column :works, :procurement_system_file_name, :string
    add_column :works, :procurement_system_content_type, :string
    add_column :works, :procurement_system_file_size, :integer
    add_column :works, :procurement_system_update_at, :datetime
  end
end
