class CreateFormules < ActiveRecord::Migration
  def change
    create_table :formules do |t|

      t.timestamps
    end
  end
end
