class AddColumnRendicionToProvision < ActiveRecord::Migration
  def change
    add_column :provisions, :rendicion, :string
  end
end
