class AddComentsToWorkerContracts < ActiveRecord::Migration
  def change
  	add_column :worker_contracts,:comment, :string
  	add_column :worker_contracts,:document, :string
    add_column :worker_contracts,:document_file_name, :string
    add_column :worker_contracts,:document_content_type, :string
    add_column :worker_contracts,:document_file_size, :integer
    add_column :worker_contracts,:document_updated_at, :datetime
  end
end
