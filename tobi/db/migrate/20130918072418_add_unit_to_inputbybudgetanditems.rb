class AddUnitToInputbybudgetanditems < ActiveRecord::Migration
  def change
    add_column :inputbybudgetanditems, :unit, :string
  end
end
