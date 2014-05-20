class AddSubbudgetdetailToItembywbses < ActiveRecord::Migration
  def change
    add_column :itembywbses, :subbudgetdetail, :string
  end
end
