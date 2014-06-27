class CreateInterestLinks < ActiveRecord::Migration
  def change
    create_table :interest_links do |t|
      t.string :name
      t.string :url
      t.string :description

      t.timestamps
    end
  end
end
