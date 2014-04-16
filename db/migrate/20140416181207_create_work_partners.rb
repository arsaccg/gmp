class CreateWorkPartners < ActiveRecord::Migration
  def change
    create_table :work_partners do |t|
      t.string :name

      t.timestamps
    end
  end
end
