class CreateDistributionItems < ActiveRecord::Migration
  def change
    create_table :distribution_items do |t|
      t.integer :distribution_id
      t.string :month
      t.float :value

      t.timestamps
    end
  end
end
