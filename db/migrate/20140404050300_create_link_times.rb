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

    @fromDate = Date.parse("01-01-2000")
    @toDate = Date.parse("31-12-2030")
    @year = @fromDate.strftime("%Y").to_i
    @week = 1
    @i = 0

    # Load Data Link Time
    (@fromDate .. @toDate).each do |x|
      @i += 1
      # Year Changed
      if @year != x.strftime("%Y").to_i
        @year = x.strftime("%Y").to_i
        @week = 1
        @i = 1
      end
      LinkTime.create({:date => x, :year => x.strftime("%Y"), :month => x.strftime("%m"), :day => x.strftime("%d"), :week => @week })
      if @i % 7 == 0
        @week += 1
      end
    end

  end

  def self.down
    drop_table :link_times
  end
end