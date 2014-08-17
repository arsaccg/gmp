class AddColummIdToQaQc < ActiveRecord::Migration
  def change
    add_column :qa_qcs, :type_of_qa_qc_id, :integer
  end
end
