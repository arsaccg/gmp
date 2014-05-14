class AddColumnToOtherWork < ActiveRecord::Migration
  def change
    add_column :other_works, :specialty, :string
  end
end
