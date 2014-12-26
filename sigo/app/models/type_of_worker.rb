class TypeOfWorker < ActiveRecord::Base
  has_many :workers
  has_many :type_of_payslip

  include ActiveModel::Validations
  validates :name, :uniqueness => { :message => "El nombre debe ser unico."}, :allow_blank => true, :case_sensitive => false
end
