class AddColumn2ToMajor < ActiveRecord::Migration
  def change
    add_column :majors, :professional_id, :integer
  end
end
