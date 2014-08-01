class CreateLinkTimes < ActiveRecord::Migration
  def self.up
    create_table :link_times do |t|
      t.date :date
      t.integer :year
      t.integer :month
      t.integer :week
      t.integer :day

      t.timestamps
      
    end
  end

  def self.down
    drop_table :link_times
  end
end