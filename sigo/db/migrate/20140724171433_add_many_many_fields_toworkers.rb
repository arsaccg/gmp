class AddManyManyFieldsToworkers < ActiveRecord::Migration
  def change
    add_column :workers, :workday, :string
    add_column :workers, :disabled, :string
    add_column :workers, :unionized, :string
    add_column :workers, :situation, :string
    add_column :workers, :state, :string
    add_column :workers, :income_fifth_category, :string
  end
end
