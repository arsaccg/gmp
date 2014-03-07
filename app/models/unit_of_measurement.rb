class UnitOfMeasurement < ActiveRecord::Base
	has_many :article_unit_of_measurements#, :through => :article_unit_of_measurements
	#accepts_nested_attributes_for :articles
end
