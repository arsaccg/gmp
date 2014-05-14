class AddColumnsFiletToWorks < ActiveRecord::Migration
  def change
    add_column :works, :budget, :string
    add_column :works, :budget_file_name, :string
    add_column :works, :budget_content_type, :string
    add_column :works, :budget_file_size, :integer
    add_column :works, :budget_updated_at, :datetime
    add_column :works, :integrated_bases, :string
    add_column :works, :integrated_bases_file_name, :string
    add_column :works, :integrated_bases_content_type, :string
    add_column :works, :integrated_bases_file_size, :integer
    add_column :works, :integrated_bases_updated_at, :datetime
  end
end
