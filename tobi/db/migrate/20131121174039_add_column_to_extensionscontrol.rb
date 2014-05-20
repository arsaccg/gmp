class AddColumnToExtensionscontrol < ActiveRecord::Migration
  def change
    add_column :extensionscontrols, :files, :string
  end
end
