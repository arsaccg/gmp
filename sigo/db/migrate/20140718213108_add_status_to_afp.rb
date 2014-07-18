class AddStatusToAfp < ActiveRecord::Migration
  def change
    add_column :afps, :status, :integer
  end
end
