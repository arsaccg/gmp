# enconding: urf-8
class TypeOfArticle < ActiveRecord::Base
	has_many :articles

	#Validaciones
	include ActiveModel::Validations
	#validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }
	validates :code, :uniqueness => { :message => "El código debe ser único."}
end
