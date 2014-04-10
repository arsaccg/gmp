class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.integer :professional_id
      t.integer :work_id
      t.string :charge
      t.string :contractor
      t.date :star_date
      t.date :finish_date
      t.integer :componetns_id
      t.string :certificate
      t.string :certificate_file_name
      t.string :certificate_content_type
      t.integer :certificate_file_size
      t.datetime :certificate_updated_at

      t.timestamps
    end
  end
end
