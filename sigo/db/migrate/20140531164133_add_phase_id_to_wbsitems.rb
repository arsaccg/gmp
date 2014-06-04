class AddPhaseIdToWbsitems < ActiveRecord::Migration
  def change
    add_column :wbsitems, :phase_id, :integer
  end
end
