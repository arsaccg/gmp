class AddColumnCertificateToOtherWork < ActiveRecord::Migration
  def change
    add_column :other_works, :certificate_id, :integer
  end
end
