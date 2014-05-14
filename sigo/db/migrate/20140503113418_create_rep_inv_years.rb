class CreateRepInvYears < ActiveRecord::Migration
  def change
    create_table :rep_inv_years, :id => false, :primary_key => {:user => :id} do |t|
      t.integer :user
      t.integer :id

      t.timestamps
    end
  end
end
