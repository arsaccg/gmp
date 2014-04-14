class RemoveColumnProfessionFromProfessional < ActiveRecord::Migration
  def change
  	remove_column :professionals, :profession, :string
  end
end
