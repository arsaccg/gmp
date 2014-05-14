class CreateCenterOfAttentions < ActiveRecord::Migration
  def change
    create_table :center_of_attentions do |t|
      t.string :name

      t.timestamps
    end
  end
end
