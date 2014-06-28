class CreateLawAndRegulations < ActiveRecord::Migration
  def change
    create_table :law_and_regulations do |t|
      t.string :name
      t.string :description
      t.string :document
      t.string :document_file_name
      t.string :document_content_type
      t.integer :document_file_size
      t.datetime :document_update_at

      t.timestamps
    end
  end
end
