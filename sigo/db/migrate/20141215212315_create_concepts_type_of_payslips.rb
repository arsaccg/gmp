class CreateConceptsTypeOfPayslips < ActiveRecord::Migration
  def change
    create_table :concepts_type_of_payslips do |t|
      t.integer :concept_id
      t.integer :type_of_payslip_id

      t.timestamps
    end
  end
end
