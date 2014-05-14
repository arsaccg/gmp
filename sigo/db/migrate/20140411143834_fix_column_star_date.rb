class FixColumnStarDate < ActiveRecord::Migration
  def change
    rename_column :certificates, :star_date, :start_date
  end
end
