class CreatePartWorkDetails < ActiveRecord::Migration
  def change
    create_table :part_work_details do |t|
      t.integer :part_work_id
      t.integer :article_id
      t.float :bill_of_quantitties
      t.text :description

      t.timestamps
    end
  end
end
