class CreateDocumentProvisions < ActiveRecord::Migration
  def change
    create_table :document_provisions do |t|
      t.string :name

      t.timestamps
    end
  end
end
