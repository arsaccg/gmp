class AddColumnStatusToConcept < ActiveRecord::Migration
  def change
    add_column :concepts, :status, :integer
  end
end
