class AddColumnSpecialtyToComponents < ActiveRecord::Migration
  def change
  	add_column :components, :specialty, :string
  end
end
