class AddColumn2ToProfessional < ActiveRecord::Migration
  def change
    add_column :professionals, :major_id, :integer
  end
end
