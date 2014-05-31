class AddCodeToScValuations < ActiveRecord::Migration
  def change
    add_column :sc_valuations, :code, :string
  end
end
