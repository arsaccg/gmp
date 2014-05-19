class AddItembybudgetIdToItembywbses < ActiveRecord::Migration
  def change
    add_column :itembywbses, :itembybudget_id, :integer
  end
end
