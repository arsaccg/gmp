class AddColumnStatusAndTimelineToCostCenters < ActiveRecord::Migration
  def change
    add_column :cost_centers, :start_date, :date
    add_column :cost_centers, :end_date, :date
    add_column :cost_centers, :status, :string
  end
end
