class CreateOfCompaniesTypeOfCompanies < ActiveRecord::Migration
  def change
    create_table :of_companies_type_of_companies do |t|
      t.integer :of_company_id
      t.integer :type_of_company_id

      t.timestamps
    end
  end
end
