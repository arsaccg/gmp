class CreateEnvironments < ActiveRecord::Migration
  def change
    create_table :environments do |t|
      t.string :name
      t.string :description
      t.integer :cost_center_id
      t.string :document
      t.string :document_file_name
      t.string :document_content_type
      t.datetime :document_updated_at
      t.integer :document_file_size

      t.timestamps
    end
  end
end