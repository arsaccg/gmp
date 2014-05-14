class CreateProfessionals < ActiveRecord::Migration
  def change
    create_table :professionals do |t|
      t.string :name
      t.integer :dni
      t.string :profession
      t.date :professional_title_date
      t.date :date_of_tuition
      t.string :professional_title
      t.string :professional_title_file_name
      t.string :professional_title_content_type
      t.integer :professional_title_file_size
      t.datetime :professional_title_updated_at
      t.string :tuition
      t.string :tuition_file_name
      t.string :tuition_content_type
      t.integer :tuition_file_size
      t.datetime :tuition_updated_at

      t.timestamps
    end
  end
end
