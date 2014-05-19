class AddOwneritemToInputbybudgetanditems < ActiveRecord::Migration
  def change
    add_column :inputbybudgetanditems, :owneritem, :string
  end
end
