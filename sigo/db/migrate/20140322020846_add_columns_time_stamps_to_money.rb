class AddColumnsTimeStampsToMoney < ActiveRecord::Migration
  def change
  	drop_table :money

  	create_table :money do |t|
      t.string :name
      t.string :symbol

      t.timestamps
    end
  end
end
