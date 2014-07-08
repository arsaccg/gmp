class AddSomeColumnsToTables < ActiveRecord::Migration
  def change
  	unless column_exists? :center_of_attentions, :cost_center_id
      add_column :center_of_attentions, :cost_center_id, :integer
    end

    unless column_exists? :part_works, :cost_center_id
      add_column :part_works, :cost_center_id, :integer
	end

    unless column_exists? :subcontract_equipments, :cost_center_id
      add_column :subcontract_equipments, :cost_center_id, :integer
    end

    unless column_exists? :subcontracts, :cost_center_id
      add_column :subcontracts, :cost_center_id, :integer
	end

    unless column_exists? :workers, :cost_center_id
      add_column :workers, :cost_center_id, :integer
	end

    unless column_exists? :part_people, :cost_center_id
      add_column :part_people, :cost_center_id, :integer
	end

    unless column_exists? :sectors, :code
      add_column :sectors, :code, :string
	end

  end
end
