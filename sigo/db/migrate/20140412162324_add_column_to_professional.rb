class AddColumnToProfessional < ActiveRecord::Migration
  def change
    add_column :professionals, :code_tuition, :string
  end
end
