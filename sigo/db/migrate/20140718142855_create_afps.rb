class CreateAfps < ActiveRecord::Migration
  def change
    create_table :afps do |t|
      t.string :enterprise
      t.float :percentage
      t.timestamps
    end
  end
end
