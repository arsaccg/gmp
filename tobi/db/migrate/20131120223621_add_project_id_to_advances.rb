class AddProjectIdToAdvances < ActiveRecord::Migration
  def change
    add_column :advances, :project_id, :integer
  end
end
