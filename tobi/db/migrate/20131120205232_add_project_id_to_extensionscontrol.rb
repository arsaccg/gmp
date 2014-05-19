class AddProjectIdToExtensionscontrol < ActiveRecord::Migration
  def change
    add_column :extensionscontrols, :project_id, :integer
  end
end
