class CreateValorizationitems < ActiveRecord::Migration
  def change
    create_table :valorizationitems do |t|
      t.integer :valorization_id
      t.integer :itembybudget_id
      t.float :actual_measured

      t.timestamps
    end
  end
end
