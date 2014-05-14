class CreateTrainings < ActiveRecord::Migration
  def change
    create_table :trainings do |t|
      t.integer :professional_id
      t.string :type_training
      t.string :training
      t.string :training_file_name
      t.string :training_content_type
      t.integer :training_file_size
      t.datetime :training_updated_at

      t.timestamps
    end
  end
end
