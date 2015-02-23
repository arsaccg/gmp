class Addpercentagetoitembybudget < ActiveRecord::Migration
  def change
    add_column :itembybudgets, :percentage,        :float,   :limit => 25, :default => 0
  end
end
