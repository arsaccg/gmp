class AddColumnApprovedMggToExtensionscontrol < ActiveRecord::Migration
  def change
    add_column :extensionscontrols, :approved_mgg, :float
  end
end
