class AddAccumulatedMeasuredToValorizationitems < ActiveRecord::Migration
  def change
    add_column :valorizationitems, :accumulated_measured, :float
  end
end
