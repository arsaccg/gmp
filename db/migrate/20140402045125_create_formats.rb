class CreateFormats < ActiveRecord::Migration
  def change
    create_table :formats do |t|
      t.string :name
      t.string :description
      t.string :status
      t.integer :user_inserts_id
      t.integer :user_updates_id

      t.timestamps
    end
  end
end