class AddColumnfToProfessionals < ActiveRecord::Migration
  def change
    add_column :professionals, :cv, :string
    add_column :professionals, :cv_file_name, :string
    add_column :professionals, :cv_content_type, :string
    add_column :professionals, :cv_file_size, :integer
    add_column :professionals, :cv_updated_at, :datetime
  end
end
