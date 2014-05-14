class AddProjectIdToItembywbses < ActiveRecord::Migration
  def change
    add_column :itembywbses, :project_id, :float
  end
end
