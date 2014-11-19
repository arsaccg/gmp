class RenameTableTypeOfQaQc < ActiveRecord::Migration
  def change
  	rename_table :type_of_qa_qcs, :type_of_qa_qc_qualities
  end
end