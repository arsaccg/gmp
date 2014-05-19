class AddFaseToWbsitem < ActiveRecord::Migration
  def change
    add_column :wbsitems, :fase, :string
  end
end
