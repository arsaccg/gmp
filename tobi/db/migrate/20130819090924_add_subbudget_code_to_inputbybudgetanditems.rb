class AddSubbudgetCodeToInputbybudgetanditems < ActiveRecord::Migration
  def change
    add_column :inputbybudgetanditems, :budget_code, :string
  end
end
