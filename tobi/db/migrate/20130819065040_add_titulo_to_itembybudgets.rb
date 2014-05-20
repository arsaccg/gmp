class AddTituloToItembybudgets < ActiveRecord::Migration
  def change
    add_column :itembybudgets, :title, :string
  end
end
