class CreateGraphers < ActiveRecord::Migration
  def change
    create_table :graphers do |t|

      t.timestamps
    end
  end
end
