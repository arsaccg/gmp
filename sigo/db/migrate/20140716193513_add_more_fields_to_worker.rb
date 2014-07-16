class AddMoreFieldsToWorker < ActiveRecord::Migration
  def change
  	unless column_exists? :workers, :quality
      add_column :workers, :quality, :string
    end
    unless column_exists? :workers, :security
      add_column :workers, :security, :string
    end
    unless column_exists? :workers, :enviroment
      add_column :workers, :enviroment, :string
    end
    unless column_exists? :workers, :labor_legislation
      add_column :workers, :labor_legislation, :string
    end
  end
end
