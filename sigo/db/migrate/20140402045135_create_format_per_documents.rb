class CreateFormatPerDocuments < ActiveRecord::Migration
  def change
    create_table :format_per_documents do |t|
      t.references :document, index: true
      t.references :format, index: true
      t.string :status
      t.integer :user_inserts_id
      t.integer :user_updates_id

      t.timestamps
    end
  end
end
