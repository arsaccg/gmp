class CreateWorkerFamiliars < ActiveRecord::Migration
  def change
    create_table :worker_familiars do |t|
    	t.string :paternal_surname
      t.string :maternal_surname
      t.string :names
      t.string :relationship
      t.date :dateofbirth
      t.string :dni
      t.timestamps
    end
  end
end
