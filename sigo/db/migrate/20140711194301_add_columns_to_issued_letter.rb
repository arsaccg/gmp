class AddColumnsToIssuedLetter < ActiveRecord::Migration
  def change
    add_column :issued_letters, :code, :string
    add_column :issued_letters, :year, :integer
  end
end
