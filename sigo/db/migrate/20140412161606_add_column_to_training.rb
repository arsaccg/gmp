class AddColumnToTraining < ActiveRecord::Migration
  def change
    add_column :trainings, :name_training, :string
  end
end
