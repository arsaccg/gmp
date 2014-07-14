class AddLicenseDriverToEntities < ActiveRecord::Migration
  def change
  	add_column :entities, :city, :string
  	add_column :entities, :province, :string
  	add_column :entities, :department, :string
  	add_column :entities, :driverlicense, :string
  	add_column :entities, :alienslicense, :string
  	add_column :entities, :maritalstatus, :string
  end
end
