class AddColumn2ToTraining < ActiveRecord::Migration
  def change
    add_column :trainings, :num_hours, :integer
    add_column :trainings, :start_training, :date
    add_column :trainings, :finish_training, :date
  end
end
