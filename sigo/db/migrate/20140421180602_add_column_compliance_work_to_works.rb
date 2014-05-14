class AddColumnComplianceWorkToWorks < ActiveRecord::Migration
  def change
    add_column :works, :compliance_work, :string
    add_column :works, :compliance_work_file_name, :string
    add_column :works, :compliance_work_content_type, :string
    add_column :works, :compliance_work_file_size, :integer
    add_column :works, :compliance_work_update_at, :datetime
  end
end
