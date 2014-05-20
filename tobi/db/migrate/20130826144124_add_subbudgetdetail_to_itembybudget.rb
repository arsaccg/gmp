class AddSubbudgetdetailToItembybudget < ActiveRecord::Migration
  def change
    add_column :itembybudgets, :subbudgetdetail, :string
  end
end
