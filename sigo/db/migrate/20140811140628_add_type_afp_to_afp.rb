class AddTypeAfpToAfp < ActiveRecord::Migration
  def change
    add_column :afps, :type_of_afp, :string
  end
end
