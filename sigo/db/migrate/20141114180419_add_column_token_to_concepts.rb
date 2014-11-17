class AddColumnTokenToConcepts < ActiveRecord::Migration
  def change
    add_column :concepts, :token, :string
  end
end
