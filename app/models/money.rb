# enconding: urf-8
class Money < ActiveRecord::Base

	# Validaciones
	include ActiveModel::Validations
	#validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }
	#validates :name, :presence => true
	validates :name, :uniqueness => { :case_sensitive => false }
	validates :symbol, :uniqueness => { :case_sensitive => false }
	validates_presence_of :name
	validates_presence_of :symbol
	validates_presence_of :exchange_rate

end
