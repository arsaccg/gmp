class TypeOfQaQc < ActiveRecord::Base
	self.table_name = 'type_of_qa_qc_qualities'
	has_many :qa_qcs
end
