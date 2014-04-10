class CreateProfessionalTrainings < ActiveRecord::Migration
  def change
    create_table :professional_trainings do |t|
      t.integer :professional_id
      t.integer :training_id

      t.timestamps
    end
  end
end
