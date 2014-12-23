class TypeOfWorker < ActiveRecord::Base
  has_many :workers
  has_many :type_of_payslip
end
