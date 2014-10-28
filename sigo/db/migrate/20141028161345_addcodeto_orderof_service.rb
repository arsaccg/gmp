class AddcodetoOrderofService < ActiveRecord::Migration
  def change
    add_column :order_of_services, :code, :string
  end
end
