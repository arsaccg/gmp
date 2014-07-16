class AddEducationForWorkers < ActiveRecord::Migration
  def change
  	unless column_exists? :workers, :primaryschool
      add_column :workers, :primaryschool, :string
    end
    unless column_exists? :workers, :highschool
      add_column :workers, :highschool, :string
    end
    unless column_exists? :workers, :primarydistrict
      add_column :workers, :primarydistrict, :string
    end
    unless column_exists? :workers, :highschooldistrict
      add_column :workers, :highschooldistrict, :string
    end
    unless column_exists? :workers, :primarystartdate
      add_column :workers, :primarystartdate, :date
    end
    unless column_exists? :workers, :primaryenddate
      add_column :workers, :primaryenddate, :date
    end
    unless column_exists? :workers, :highschoolstartdate
      add_column :workers, :highschoolstartdate, :date
    end
    unless column_exists? :workers, :highschoolenddate
      add_column :workers, :highschoolenddate, :date
    end
    unless column_exists? :workers, :levelofinstruction
      add_column :workers, :levelofinstruction, :string
    end
  end
end
