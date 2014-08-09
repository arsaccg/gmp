class CreateGeneralExpenseDetails < ActiveRecord::Migration
  def change
    if !table_exists? :general_expense_details
      create_table :general_expense_details do |t|
        t.integer :general_expense_id
        t.string :type_article
        t.integer :article_id      
        t.integer :people
        t.float :participation
        t.float :time
        t.float :salary
        t.float :parcial
        t.float :amount
        t.float :cost

        t.timestamps
      end
    end
  end
end
