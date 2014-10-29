class ChangePriceOfInputbybudgetanditems < ActiveRecord::Migration
  def change
  	change_column :inputbybudgetanditems, :price,  :string
  end
end
