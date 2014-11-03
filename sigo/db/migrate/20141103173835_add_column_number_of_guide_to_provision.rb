class AddColumnNumberOfGuideToProvision < ActiveRecord::Migration
  def change
    add_column :provisions, :number_of_guide, :string
  end
end
