class AddStartDateToWbsitems < ActiveRecord::Migration
  def change
    add_column :wbsitems, :start_date, :datetime
  end
end
