class UnitOfMeasurement < ActiveRecord::Base
	include ActiveModel::Validations

	has_many :article_unit_of_measurements#, :through => :article_unit_of_measurements
	#accepts_nested_attributes_for :articles

	# Validaciones
	validates :code, :uniqueness => { :message => "El código debe ser único"}
end
