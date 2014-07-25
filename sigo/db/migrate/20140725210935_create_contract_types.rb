class CreateContractTypes < ActiveRecord::Migration
  def change
    create_table :contract_types do |t|
      t.string :description
      t.string :shortdescription      

      t.timestamps
    end
  end
end
