class FixColumnParcialGe < ActiveRecord::Migration
  def change
  	change_column :general_expense_details, :parcial, :string
  end
end
