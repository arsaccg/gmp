class TypeOfPayslip < ActiveRecord::Base
  has_and_belongs_to_many :concepts
  belongs_to :payslip
  belongs_to :type_of_worker
end
