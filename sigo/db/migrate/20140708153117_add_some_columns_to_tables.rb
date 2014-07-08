class AddSomeColumnsToTables < ActiveRecord::Migration
  def change
    add_column :center_of_attentions, :cost_center_id, :integer
    add_column :part_works, :cost_center_id, :integer
    add_column :subcontract_equipments, :cost_center_id, :integer
    add_column :subcontracts, :cost_center_id, :integer
    add_column :workers, :cost_center_id, :integer
    add_column :part_people, :cost_center_id, :integer
    add_column :sectors, :code, :string
  end
end
