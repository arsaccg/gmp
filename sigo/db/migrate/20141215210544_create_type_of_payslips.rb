class CreateTypeOfPayslips < ActiveRecord::Migration
  def change
    create_table :type_of_payslips do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
