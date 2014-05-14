class AddColumnToCertificate < ActiveRecord::Migration
  def change
    add_column :certificates, :other, :string
    add_column :certificates, :other_file_name, :string
    add_column :certificates, :other_content_type, :string
    add_column :certificates, :other_file_size, :integer
    add_column :certificates, :other_updated_at, :datetime
  end
end
