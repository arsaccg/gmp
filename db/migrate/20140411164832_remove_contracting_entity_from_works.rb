class RemoveContractingEntityFromWorks < ActiveRecord::Migration
  def change
    remove_column :works, :contracting_entity, :string
  end
end
