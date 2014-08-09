class AddOnpafpToWorkers < ActiveRecord::Migration
  def change
    add_column :workers,:onpafp, :string
  end
end
