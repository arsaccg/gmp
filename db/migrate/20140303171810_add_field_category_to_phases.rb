class AddFieldCategoryToPhases < ActiveRecord::Migration
  def change
    add_column :phases, :category, :string
  end
end
