class AddColumnPartPersonIdToPartPersonDetails < ActiveRecord::Migration
  def change
    add_column :part_person_details, :part_person_id, :integer
  end
end
