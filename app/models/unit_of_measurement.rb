class UnitOfMeasurement < ActiveRecord::Base
	has_many :articles, :through => :article_unit_of_measurements
end
