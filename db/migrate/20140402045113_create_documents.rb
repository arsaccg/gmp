class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :name
      t.string :description
      t.string :status
      t.integer :user_inserts_id
      t.integer :user_updates_id

      t.timestamps
    end
  end
end
