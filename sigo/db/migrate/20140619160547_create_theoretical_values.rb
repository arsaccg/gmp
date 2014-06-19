class CreateTheoreticalValues < ActiveRecord::Migration
  def change
    create_table :theoretical_values do |t|
    	t.integer :article_id
      t.float :theoretical_value
      t.timestamps
    end
  end
end
