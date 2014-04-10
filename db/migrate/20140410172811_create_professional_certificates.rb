class CreateProfessionalCertificates < ActiveRecord::Migration
  def change
    create_table :professional_certificates do |t|
      t.integer :professional_id
      t.integer :certificate_id

      t.timestamps
    end
  end
end
