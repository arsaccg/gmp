class AddFaseIdToWbsitem < ActiveRecord::Migration
  def change
    add_column :wbsitems, :fase_id, :integer
  end
end
