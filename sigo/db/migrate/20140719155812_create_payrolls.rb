class CreatePayrolls < ActiveRecord::Migration
  def change
    if !table_exists? :payrolls
      create_table :payrolls do |t|
        t.integer :worker_id
        t.integer :status

        t.timestamps
      end
    end
  end
end

