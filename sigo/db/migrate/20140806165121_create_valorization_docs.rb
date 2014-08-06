class CreateValorizationDocs < ActiveRecord::Migration
  def change
    create_table :valorization_docs do |t|
      t.string :name
      t.string :description
      t.integer :cost_center_id
      t.integer :type_of_valorization_doc_id
      t.string :document
      t.string :document_file_name
      t.string :document_content_type
      t.integer :document_file_size
      t.datetime :document_updated_at

      t.timestamps
    end
  end
end
