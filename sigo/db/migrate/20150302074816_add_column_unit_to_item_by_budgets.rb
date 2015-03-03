class AddColumnUnitToItemByBudgets < ActiveRecord::Migration
  def change
    add_column :itembybudgets, :unit, :string
  end
end
