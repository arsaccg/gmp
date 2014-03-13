class AddColumnAbbreviationToCenterOfAttentions < ActiveRecord::Migration
  def change
    add_column :center_of_attentions, :abbreviation, :string
  end
end
