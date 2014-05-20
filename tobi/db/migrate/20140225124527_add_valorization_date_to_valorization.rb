class AddValorizationDateToValorization < ActiveRecord::Migration
  def change
    add_column :valorizations, :valorization_date, :date
  end
end
