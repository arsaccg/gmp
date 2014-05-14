class CreateCertificatesProfessionals < ActiveRecord::Migration
  def change
    create_table :certificates_professionals do |t|
      t.integer :certificate_id
      t.integer :professional_id

      t.timestamps
    end
  end
end
