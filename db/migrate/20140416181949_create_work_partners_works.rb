class CreateWorkPartnersWorks < ActiveRecord::Migration
  def change
    create_table :work_partners_works do |t|
      t.integer :work_id
      t.integer :work_partner_id

      t.timestamps
    end
  end
end
