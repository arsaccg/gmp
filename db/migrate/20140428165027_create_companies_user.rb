class CreateCompaniesUser < ActiveRecord::Migration
  def change
    create_table :companies_users do |t|
      t.integer :company_id
      t.integer :user_id
      t.timestamps
    end
  end
end
