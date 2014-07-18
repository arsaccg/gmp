class CreateAfpDetails < ActiveRecord::Migration
  def change
    create_table :afp_details do |t|
      t.integer :afp_id
      t.float :percentage
      t.date :date_entry
      t.integer :status

      t.timestamps
    end
  end
end
