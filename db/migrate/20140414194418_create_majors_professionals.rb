class CreateMajorsProfessionals < ActiveRecord::Migration
  def change
    create_table :majors_professionals do |t|
      t.integer :major_id
      t.integer :professional_id

      t.timestamps
    end
  end
end
