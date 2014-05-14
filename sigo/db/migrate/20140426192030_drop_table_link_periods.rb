class DropTableLinkPeriods < ActiveRecord::Migration
  def change
  	drop_table :link_periods
  end
end
