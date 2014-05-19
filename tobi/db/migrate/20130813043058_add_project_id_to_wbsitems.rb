class AddProjectIdToWbsitems < ActiveRecord::Migration
  def change
    add_column :wbsitems, :project_id, :integer
  end
end
