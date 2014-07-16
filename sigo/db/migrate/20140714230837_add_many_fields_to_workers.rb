class AddManyFieldsToWorkers < ActiveRecord::Migration
  def change
    unless column_exists? :workers, :address
      add_column :workers, :address, :string
    end
    unless column_exists? :workers, :district
      add_column :workers, :district, :string
    end
    unless column_exists? :workers, :province
      add_column :workers, :province, :string
    end
    unless column_exists? :workers, :department
      add_column :workers, :department, :string
    end
    unless column_exists? :workers, :country
      add_column :workers, :country, :string
    end
    unless column_exists? :workers, :phone
      add_column :workers, :phone, :string
    end
    unless column_exists? :workers, :cellphone
      add_column :workers, :cellphone, :string
    end
    unless column_exists? :workers, :email
      add_column :workers, :email, :string
    end
  end
end
