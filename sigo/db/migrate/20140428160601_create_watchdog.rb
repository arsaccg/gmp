class CreateWatchdog < ActiveRecord::Migration
  def change
    create_table :watchdogs do |t|
      t.string :user_id
      t.string :browser
      t.string :ip_address
      t.string :note

      t.timestamps
    end
  end
end
