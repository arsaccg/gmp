class RemoveColumnPartPeopleIdFromPartPersonDetails < ActiveRecord::Migration
  def change
    remove_column :part_person_details, :part_people_id
  end
end
