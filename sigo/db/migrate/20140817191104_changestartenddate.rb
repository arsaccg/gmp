class Changestartenddate < ActiveRecord::Migration
  def change
    change_column :workers, :primarystartdate,  :integer
    change_column :workers, :primaryenddate,  :integer
    change_column :workers, :highschoolstartdate,  :integer
    change_column :workers, :highschoolenddate,  :integer
    change_column :worker_experiences, :start_date,  :integer
    change_column :worker_experiences, :end_date,  :integer
  end
end