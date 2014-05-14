class CreateBanks < ActiveRecord::Migration
  def change
    create_table :banks do |t|
      t.string :business_name
      t.string :ruc

      t.timestamps
    end
  end
end
