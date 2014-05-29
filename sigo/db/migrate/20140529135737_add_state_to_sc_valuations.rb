class AddStateToScValuations < ActiveRecord::Migration
  def change
    add_column :sc_valuations, :state, :string
  end
end
