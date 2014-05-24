class UnitOfMeasurement < ActiveRecord::Base
	include ActiveModel::Validations

	has_many :articles#, :through => :article_unit_of_measurements
	#accepts_nested_attributes_for :articles
	has_many :category_of_worker
	# Validaciones
	include ActiveModel::Validations
	#validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }
	validates :code, :uniqueness => { :message => "El código debe ser único."}
end
