class AddWbsitemIdToItembywbses < ActiveRecord::Migration
  def change
    add_column :itembywbses, :wbsitem_id, :integer
  end
end
