class CreateTypeOfContractualDocuments < ActiveRecord::Migration
  def change
  	if !table_exists? :type_of_contractual_documents
	    create_table :type_of_contractual_documents do |t|
	      t.string :name
	      t.string :preffix
	      t.integer :cost_center_id

	      t.timestamps
	    end
	  end
  end
end
