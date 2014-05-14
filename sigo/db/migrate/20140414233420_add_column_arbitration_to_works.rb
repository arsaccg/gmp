class AddColumnArbitrationToWorks < ActiveRecord::Migration
  def change
    add_column :works, :arbitration, :string
    add_column :works, :arbitration_file_name, :string
    add_column :works, :arbitration_content_type, :string
    add_column :works, :arbitration_file_size, :integer
    add_column :works, :arbitration_updated_at, :datetime
  end
end
