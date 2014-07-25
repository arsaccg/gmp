class CreateHealthCenters < ActiveRecord::Migration
  def change
    create_table :health_centers do |t|
      t.string :enterprise

      t.timestamps
    end
  end
end
