class TypeOfPayslip < ActiveRecord::Base
  has_and_belongs_to_many :concepts
  belongs_to :payslip
end
