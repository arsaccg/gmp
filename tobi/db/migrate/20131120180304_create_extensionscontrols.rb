class CreateExtensionscontrols < ActiveRecord::Migration
  def change
    create_table :extensionscontrols do |t|
      t.string :description
      t.string :motive
      t.string :status
      t.float :requested_deadline
      t.float :approved_deadline
      t.float :requested_mgg
      t.string :resolution
      t.string :observation

      t.timestamps
    end
  end
end
