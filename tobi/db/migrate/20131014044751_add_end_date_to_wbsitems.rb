class AddEndDateToWbsitems < ActiveRecord::Migration
  def change
    add_column :wbsitems, :end_date, :datetime
  end
end
